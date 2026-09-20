import Foundation
import UltraCore

enum LatencyVerification {
    static func run(transport: MIDITransport, directory: URL) throws {
        var queue = RequestQueue(sendLong:{ try transport.sendSysEx($0) },send:{ try transport.send($0) })
        transport.onMessage = { bytes in
            guard UltraProtocol.validEnvelope(bytes), Array(bytes.prefix(5)) == UltraProtocol.modernHeader, bytes[5] != 0x10 else { return }
            queue.receive(bytes)
        }
        func now() -> Double { ProcessInfo.processInfo.systemUptime }
        func wait(_ done: () -> Bool) throws {
            let deadline = now()+8
            while !done() && now() < deadline { RunLoop.main.run(until:Date().addingTimeInterval(0.001)) }
            guard done() else { throw MIDIError.message("Latency test timed out") }
        }
        func request(_ bytes: [UInt8], matches: @escaping ([UInt8])->Bool) throws -> [UInt8] {
            var result: Result<[UInt8],Error>?
            queue.enqueue(.init(bytes:bytes,timeout:4,matches:matches) { result = $0 })
            try wait { result != nil }; return try result!.get()
        }
        func patch() throws -> UltraPreset { try UltraPreset(message:request(UltraProtocol.patch(),matches:{ $0.count == 2060 && $0[5] == 4 })) }
        func parameter(_ raw: Int? = nil) throws -> ParameterValue {
            let bytes = try request(UltraProtocol.parameter(effect:106,parameter:1,value:raw),matches:{ UltraProtocol.response($0)?.key == "106:1" })
            guard let value = UltraProtocol.response(bytes) else { throw MIDIError.message("Invalid response") }; return value
        }
        let baseline = try patch()
        try Data(baseline.message).write(to:directory.appendingPathComponent("before.syx"),options:.atomic)
        guard let original = baseline.effectParameters[106]?[1] else { throw MIDIError.message("Amp 1 Drive must be present") }
        let alternate = max(0,Int(original)-1) == Int(original) ? 1 : Int(original)-1
        var restored = false
        defer {
            if !restored {
                queue.cancel()
                do {
                    _ = try request(baseline.forEditBuffer(),matches:{ UltraProtocol.status($0,for:4) != nil })
                    guard try patch().payload == baseline.payload else { throw MIDIError.message("Recovery mismatch") }
                    print("RECOVERED original edit buffer after test failure")
                } catch { print("RESTORE FAILED: \(error). Backup: \(directory.path)/before.syx") }
            }
        }
        var cycles: [String:[Double]] = [:]
        for (label,gap) in [("previous40msGap",0.04),("nativeShortExperiment",0.0),("newNoGap",0.0)] {
            try wait { queue.count == 0 && !queue.hasForegroundWork }
            queue = RequestQueue(shortGap:gap,sendLong:{ try transport.sendSysEx($0) },send:{ if label == "nativeShortExperiment" { try transport.sendSysEx($0) } else { try transport.send($0) } })
            var times: [Double] = []
            for index in 0..<12 {
                let target = index % 2 == 0 ? alternate : Int(original), start = now()
                guard try parameter(target).raw == target, try parameter().raw == target else { throw MIDIError.message("Edit/readback mismatch") }
                try wait { queue.count == 0 && !queue.hasForegroundWork }
                times.append((now()-start)*1000)
            }
            cycles[label] = times
            print("\(label): mean complete SET/GET cycle \(times.reduce(0,+)/Double(times.count)) ms")
        }
        var rtt: [Double] = [], sentAt = 0.0, writes = 0
        queue.onSent = { bytes in if bytes.count == 14 && bytes[5] == 2 && bytes[12] == 1 { sentAt = now(); writes += 1 } }
        let edit = LiveParameterEdit(effect:106,parameter:1,initial:Int(original),header:UltraProtocol.modernHeader,queue:queue)
        var completion: Result<ParameterValue,Error>?, acknowledgedBeforeRelease = 0
        var released = false, lastUpdate = 0.0
        edit.onAcknowledged = { _ in
            if sentAt != 0 { rtt.append((now()-sentAt)*1000); sentAt = 0 }
            if !released { acknowledgedBeforeRelease += 1 }
        }
        edit.completion = { completion = $0 }
        let start = now()
        // 200 pointer events/s; only a one-unit reversible Drive variation.
        for index in 0..<200 {
            DispatchQueue.main.asyncAfter(deadline:.now()+Double(index)*0.005) {
                lastUpdate = now(); edit.update(index % 4 < 2 ? alternate : Int(original))
                if index == 199 { released = true; edit.finish() }
            }
        }
        try wait { completion != nil }
        let finish = now(), finalValue = try completion!.get()
        guard finalValue.raw == Int(original), acknowledgedBeforeRelease > 5 else { throw MIDIError.message("Live streaming did not reach final target") }
        let final = try patch()
        guard final.payload == baseline.payload else { throw MIDIError.message("Unexpected preset change") }
        try Data(final.message).write(to:directory.appendingPathComponent("after.syx"),options:.atomic)
        restored = true
        let report: [String:Any] = ["date":ISO8601DateFormatter().string(from:Date()),"cyclesMilliseconds":cycles,
            "inputEvents":200,"streamWrites":writes,"acknowledgementsBeforeRelease":acknowledgedBeforeRelease,
            "setRoundTripMilliseconds":rtt,"gestureDurationMilliseconds":(finish-start)*1000,
            "releaseToFinalReadbackMilliseconds":(finish-lastUpdate)*1000,"beforeSHA256":baseline.fingerprint,
            "afterSHA256":final.fingerprint,"persistentSlotWrites":0,"audioOnsetMeasured":false]
        try JSONSerialization.data(withJSONObject:report,options:[.prettyPrinted,.sortedKeys]).write(to:directory.appendingPathComponent("latency.json"))
        print("PASS \(writes) live writes, \(acknowledgedBeforeRelease) acknowledged before release; final readback \((finish-lastUpdate)*1000) ms after release")
        print("PASS complete preset restored byte-for-byte; no stored slots written")
    }
}
