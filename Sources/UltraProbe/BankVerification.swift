import Foundation
import UltraCore

enum BankVerification {
    static func run(transport: MIDITransport, directory: URL) throws {
        let queue = RequestQueue(sendLong:{ try transport.sendSysEx($0) },send:{ try transport.send($0) })
        transport.onMessage = { if UltraProtocol.validEnvelope($0) { queue.receive($0) } }
        var lines: [String] = []
        func record(_ text: String) { print(text); fflush(stdout); lines.append(text) }
        defer { try? Data(lines.joined(separator:"\n").utf8).write(to:directory.appendingPathComponent("bank-verification.txt")) }
        func request(_ bytes: [UInt8], timeout: Double = 4, match: @escaping ([UInt8])->Bool) throws -> [UInt8] {
            var result: Result<[UInt8],Error>?
            queue.enqueue(.init(bytes:bytes,timeout:timeout,matches:match) { result = $0 })
            let end = Date().addingTimeInterval(timeout+4)
            while result == nil && Date()<end { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
            guard let result else { queue.cancel(); throw MIDIError.message("Bank verification timeout") }; return try result.get()
        }
        func patch() throws -> UltraPreset { try UltraPreset(message:request(UltraProtocol.patch(),match:{ $0.count == 2060 && $0[5] == 4 && $0[6] == 1 })) }
        let before = try patch(); try Data(before.message).write(to:directory.appendingPathComponent("before.syx"),options:.atomic)
        record("Baseline \(before.name) • \(before.fingerprint)")
        var presets: [UltraPreset] = []
        for bank in 0...2 {
            record("Reading bank \(["A","B","C"][bank])")
            let bytes = try request(UltraProtocol.modernHeader+[3,UInt8(bank+2),0,0,247],timeout:130,match:{ $0.count == 262156 && $0[5] == 4 && $0[6] == UInt8(bank+2) })
            try Data(bytes).write(to:directory.appendingPathComponent("bank-\(["A","B","C"][bank]).syx"),options:.atomic)
            presets += try UltraPreset.readFile(Data(bytes))
            guard try patch().payload == before.payload else { throw MIDIError.message("Active edit buffer differs after bank read") }
            record("PASS bank \(bank), 128 checksummed presets; active buffer unchanged")
        }
        let workspace = try BankWorkspace(presets:presets), exported = try workspace.export(banks:[0,1,2])
        try exported.write(to:directory.appendingPathComponent("All-384.syx"),options:.atomic)
        let decoded = try UltraPreset.readFile(exported)
        guard decoded.map(\.payload) == presets.map(\.payload) else { throw MIDIError.message("Bank round trip differs") }
        for slot in [0,127,128,130,255,256,300,383] {
            let bytes = try request(UltraProtocol.storedPreset(slot),match:{ (try? UltraPreset.storedReply($0,requestedSlot:slot)) != nil })
            let preset = try UltraPreset.storedReply(bytes,requestedSlot:slot)
            guard preset.payload == presets[slot].payload else { throw MIDIError.message("Slot \(slot) differs from bank dump") }
            record("PASS independent slot \(slot) matches bank dump")
        }
        let after = try patch(); try Data(after.message).write(to:directory.appendingPathComponent("after.syx"))
        guard after.payload == before.payload else { throw MIDIError.message("Final edit buffer differs") }
        record("PASS all 384 slots backed up, re-exported and decoded; active buffer unchanged; no writes")
    }
}
