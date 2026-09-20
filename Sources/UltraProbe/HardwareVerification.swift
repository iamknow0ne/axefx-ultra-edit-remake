import Foundation
import UltraCore

enum HardwareVerification {
    static func run(transport: MIDITransport, header: [UInt8], directory: URL, readControls: Bool = false) throws {
        try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
        let queue = RequestQueue { try transport.send($0) }
        var log: [String] = []
        func record(_ line: String) { print(line); fflush(stdout); log.append(line) }
        queue.onSent = { record("TX " + $0.prefix(24).map { String(format:"%02X",$0) }.joined(separator:" ")) }
        transport.onMessage = { bytes in
            if bytes.count > 6, bytes[5] != 0x10 { record("RX \(bytes.count) " + bytes.prefix(24).map { String(format:"%02X",$0) }.joined(separator:" ")); queue.receive(bytes) }
        }
        defer { try? Data(log.joined(separator:"\n").utf8).write(to:directory.appendingPathComponent("edit-verification.txt")) }
        func transact(_ bytes: [UInt8], match: @escaping ([UInt8])->Bool) throws -> [UInt8] {
            var reply: Result<[UInt8],Error>?
            queue.enqueue(.init(bytes:bytes,timeout:4,matches:{ UltraProtocol.validEnvelope($0) && match($0) }) { reply = $0 })
            let end = Date().addingTimeInterval(6)
            while reply == nil && Date() < end { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
            guard let reply else { queue.cancel(); throw MIDIError.message("Verification timed out") }
            return try reply.get()
        }
        func patch() throws -> UltraPreset { try UltraPreset(message:transact(UltraProtocol.patch(header:header),match:{ $0.count == 2060 && $0[5] == 4 && $0[6] == 1 })) }
        func param(_ value: Int? = nil) throws -> ParameterValue {
            let bytes = try transact(UltraProtocol.parameter(effect:106,parameter:1,value:value,header:header),match:{ UltraProtocol.response($0)?.key == "106:1" })
            guard let reply = UltraProtocol.response(bytes) else { throw MIDIError.message("Malformed parameter reply") }; return reply
        }
        let before = try patch()
        guard before.cells.contains(where: { $0.effect == 106 }) else { throw MIDIError.message("The current preset has no Amp 1. No edits sent.") }
        try Data(before.message).write(to:directory.appendingPathComponent("before-edit.syx"),options:.atomic)
        if readControls {
            let catalog = try Catalog(url:URL(fileURLWithPath:"Resources/UltraCatalog.json"))
            let effect = catalog.effect(106)!
            var count = 0
            for parameter in effect.parameters where parameter.id != effect.typeParameterID && parameter.id < (before.effectParameters[106]?.count ?? 0) {
                let id = parameter.id
                _ = try transact(UltraProtocol.parameter(effect:106,parameter:id,header:header),match:{ UltraProtocol.response($0)?.key == "106:\(id)" })
                count += 1
            }
            let after = try patch()
            try Data(after.message).write(to:directory.appendingPathComponent("after-reads.syx"))
            guard after.payload == before.payload else { throw MIDIError.message("Parameter reads changed preset data") }
            record("PASS \(count) non-selector Amp controls read; all 1024 preset bytes unchanged. Model came from the preset dump.")
            return
        }
        let original = try param()
        let target = original.raw == 0 ? 1 : original.raw - 1
        record("Before: \(before.name), Amp 1 Drive \(original.text), raw \(original.raw)")
        var restored = false
        defer {
            if !restored {
                do { let value = try param(original.raw); record("Recovery restore reply: \(value.raw)") }
                catch { record("RESTORE FAILED: \(error.localizedDescription). Restore raw Drive \(original.raw); original backup is before-edit.syx") }
            }
        }
        let set = try param(target)
        guard set.raw == target else { throw MIDIError.message("Device did not accept the test value") }
        let read = try param()
        guard read.raw == target else { throw MIDIError.message("Edited parameter readback mismatch") }
        record("PASS changed Drive to \(read.text), raw \(read.raw), and read it back")
        let restoration = try param(original.raw)
        let verified = try param()
        guard restoration.raw == original.raw && verified.raw == original.raw else { throw MIDIError.message("Original value not confirmed after restore") }
        restored = true
        let after = try patch()
        try Data(after.message).write(to:directory.appendingPathComponent("after-restore.syx"),options:.atomic)
        guard after.payload == before.payload else { throw MIDIError.message("Restored parameter matches, but preset payload differs. Backups retained for comparison.") }
        record("PASS restored original Drive \(verified.text); all 1024 preset payload bytes match the original backup")
        record("No stored preset slots were written.")
    }
}
