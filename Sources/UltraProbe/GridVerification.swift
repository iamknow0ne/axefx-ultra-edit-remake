import Foundation
import UltraCore

enum GridVerification {
    static func run(transport: MIDITransport, directory: URL, storedOnly: Bool = false) throws {
        var lines: [String] = [], checks: [String] = []
        let queue = RequestQueue(sendLong:{ try transport.sendSysEx($0) }) { try transport.send($0) }
        transport.onMessage = { if UltraProtocol.validEnvelope($0), $0[5] != 0x10 { print("RX",Array($0.prefix(9)),"size",$0.count,"name",(try? UltraPreset(message:$0))?.name ?? ""); if $0.count == 2060 { try? Data($0).write(to:directory.appendingPathComponent("last-reply.syx")) }; fflush(stdout); queue.receive($0) } }
        func record(_ text: String) { print(text); fflush(stdout); lines.append(text) }
        defer { try? Data(lines.joined(separator:"\n").utf8).write(to:directory.appendingPathComponent("grid-verification.txt")) }
        func transaction(_ bytes: [UInt8], match: @escaping ([UInt8])->Bool) throws -> [UInt8] {
            var result: Result<[UInt8],Error>?
            queue.enqueue(.init(bytes:bytes,timeout:4,matches:match) { result = $0 })
            let end = Date().addingTimeInterval(7)
            while result == nil && Date() < end { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
            guard let result else { queue.cancel(); throw MIDIError.message("Grid verification timed out") }
            return try result.get()
        }
        func patch() throws -> UltraPreset { try UltraPreset(message:transaction(UltraProtocol.patch(),match:{ $0.count == 2060 && $0[5] == 4 && $0[6] == 1 })) }
        func upload(_ preset: UltraPreset) throws {
            let reply = try transaction(preset.forEditBuffer(),match:{ UltraProtocol.status($0,for:4) != nil })
            guard UltraProtocol.status(reply,for:4) == 1 else { throw MIDIError.message("Upload rejected") }
            let actual = try patch()
            guard actual.payload == preset.payload else { try Data(actual.message).write(to:directory.appendingPathComponent("mismatch.syx")); throw MIDIError.message("Full grid readback differs") }
        }
        let baseline = try patch()
        try Data(baseline.message).write(to:directory.appendingPathComponent("before.syx"))
        record("Fresh baseline \(baseline.name) · \(baseline.fingerprint)")
        var changed = false
        defer {
            if changed {
                do { try upload(baseline); record("Recovered baseline after failure") }
                catch { record("RESTORE FAILED: \(error.localizedDescription)") }
            }
        }
        var slots: [[String:Any]] = []
        record("Reading bank C independently to validate truncated single-preset reply addresses")
        var bankResult: Result<[UInt8],Error>?
        queue.enqueue(.init(bytes:UltraProtocol.modernHeader+[3,4,0,0,0xF7],timeout:120,matches:{ $0.count == 262156 && $0[5] == 4 && $0[6] == 4 }) { bankResult = $0 })
        let bankEnd = Date().addingTimeInterval(125)
        while bankResult == nil && Date() < bankEnd { RunLoop.main.run(until:Date().addingTimeInterval(0.02)) }
        guard let bankResult else { throw MIDIError.message("Bank C read timed out") }
        let bankBytes = try bankResult.get()
        try Data(bankBytes).write(to:directory.appendingPathComponent("bank-C.syx"))
        let bankC = try UltraPreset.readFile(Data(bankBytes))
        for slot in [0,127,128,129,130,255,256,383] {
            let bytes = try transaction(UltraProtocol.storedPreset(slot),match:{ (try? UltraPreset(message:$0))?.storedSlot == (slot & 255) })
            let preset = try UltraPreset(message:bytes)
            if slot >= 256 { guard preset.payload == bankC[slot-256].payload else { throw MIDIError.message("Single read differs from independent bank C read") } }
            try Data(bytes).write(to:directory.appendingPathComponent("slot-\(slot).syx"))
            slots.append(["slot":slot,"name":preset.name,"sha256":preset.fingerprint])
            record("READ slot \(slot): \(preset.name) · header \(bytes.prefix(9))")
        }
        guard try patch().payload == baseline.payload else { throw MIDIError.message("Stored reads changed the edit buffer") }
        checks.append("Stored slots 0, 127, 128, 129, 130, 255, 256, 383; current edit buffer unchanged")
        if !storedOnly {
            guard let source = baseline.cells.first(where:{ $0.effect > 0 && $0.effect < 200 && $0.column > 0 && baseline.cells.contains(where:{ $0.effect == 0 }) }),
                  let target = baseline.cells.first(where:{ $0.column == source.column && $0.effect == 0 }) else { throw MIDIError.message("No suitable same-column move test") }
            let moved = try baseline.editingGrid(.move(source:source.id,destination:target.id))
            changed = true; try upload(moved)
            try Data(moved.message).write(to:directory.appendingPathComponent("moved.syx"))
            checks.append("Move with all effect records and attached cables preserved, 1024-byte readback")
            record("PASS move \(source.id) → \(target.id)")
            if let link = moved.gridLinks.first(where:{ $0.source == target.id || $0.destination == target.id }) {
                let disconnected = try moved.editingGrid(.link(link,enabled:false))
                try upload(disconnected); try upload(try disconnected.editingGrid(.link(link,enabled:true)))
                checks.append("Disconnect and reconnect cable, exact payload readback")
            }
            if let other = baseline.cells.first(where:{ $0.effect > 0 && $0.effect < 200 && $0.id != source.id }) {
                try upload(try baseline.editingGrid(.move(source:source.id,destination:other.id)))
                checks.append("Swap existing effects with unchanged parameter records and routing")
            }
            try upload(baseline); changed = false
        }
        let final = try patch(); guard final.payload == baseline.payload else { throw MIDIError.message("Final baseline differs") }
        try Data(final.message).write(to:directory.appendingPathComponent("after.syx"))
        let report: [String:Any] = ["date":ISO8601DateFormatter().string(from:Date()),"checks":checks,"slots":slots,"beforeSHA256":baseline.fingerprint,"afterSHA256":final.fingerprint,"persistentSlotWrites":0]
        try JSONSerialization.data(withJSONObject:report,options:[.prettyPrinted,.sortedKeys]).write(to:directory.appendingPathComponent("grid-verification.json"))
        record("PASS all checks; original restored byte-for-byte")
    }
}
