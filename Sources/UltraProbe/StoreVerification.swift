import Foundation
import UltraCore

/// Explicit opt-in persistent test. A durable backup precedes every write.
enum StoreVerification {
    static func run(transport: MIDITransport, slot: Int, directory: URL) throws {
        guard (0..<384).contains(slot) else { throw MIDIError.message("Invalid test slot") }
        let queue = RequestQueue(sendLong: { try transport.sendSysEx($0) }, send: { try transport.send($0) })
        transport.onMessage = { bytes in
            if UltraProtocol.validEnvelope(bytes), Array(bytes.prefix(5)) == UltraProtocol.modernHeader { queue.receive(bytes) }
        }
        var log: [String] = []
        func record(_ text: String) { print(text); fflush(stdout); log.append(text) }
        defer { try? Data(log.joined(separator:"\n").utf8).write(to:directory.appendingPathComponent("store-verification.txt"),options:.atomic) }
        func request(_ bytes: [UInt8], match: @escaping ([UInt8])->Bool) throws -> [UInt8] {
            var result: Result<[UInt8],Error>?
            queue.enqueue(.init(bytes:bytes,timeout:5,matches:match) { result = $0 })
            let deadline = Date().addingTimeInterval(9)
            while result == nil && Date() < deadline { RunLoop.main.run(until:Date().addingTimeInterval(0.005)) }
            guard let result else { queue.cancel(); throw MIDIError.message("Store verification timed out") }
            return try result.get()
        }
        func stored() throws -> UltraPreset {
            try UltraPreset.storedReply(request(UltraProtocol.storedPreset(slot),match: { (try? UltraPreset.storedReply($0,requestedSlot:slot)) != nil }),requestedSlot:slot)
        }
        func buffer() throws -> UltraPreset {
            try UltraPreset(message:request(UltraProtocol.patch(),match: { $0.count == 2060 && $0[5] == 4 && $0[6] == 1 }))
        }
        func write(_ preset: UltraPreset, persistent: Bool) throws {
            let message = try persistent ? preset.forStorage(slot:slot) : preset.forEditBuffer()
            let ack = try request(message,match: { UltraProtocol.status($0,for:4) != nil })
            guard UltraProtocol.status(ack,for:4) == 1 else { throw MIDIError.message("Ultra rejected transfer") }
        }
        let edit = try buffer()
        let original = try stored()
        RunLoop.main.run(until:Date().addingTimeInterval(1))
        let afterRead = try buffer()
        record("Edit buffer after stored read and 1-second settling: \(afterRead.name); unchanged: \(afterRead.payload == edit.payload)")
        try Data(original.message).write(to:directory.appendingPathComponent("slot-\(slot)-before.syx"),options:.atomic)
        try Data(edit.message).write(to:directory.appendingPathComponent("edit-buffer-before.syx"),options:.atomic)
        record("Backed up slot \(slot): \(original.name), SHA256 \(original.fingerprint)")
        guard afterRead.payload == edit.payload else { throw MIDIError.message("Active buffer did not settle after stored read; test stopped") }
        var restored = false
        defer {
            if !restored {
                queue.cancel()
                do {
                    try write(original,persistent:true)
                    guard try stored().payload == original.payload else { throw MIDIError.message("Stored recovery mismatch") }
                    if try buffer().payload != edit.payload { try write(edit,persistent:false) }
                    guard try buffer().payload == edit.payload else { throw MIDIError.message("Edit-buffer recovery mismatch") }
                    record("RECOVERED original slot and edit buffer after failure")
                } catch { record("RECOVERY FAILED: \(error.localizedDescription). Retain all backups in \(directory.path)") }
            }
        }
        let test = try original.renamed(original.name == "Ultra Store Test" ? "Ultra Store Test 2" : "Ultra Store Test")
        try write(test,persistent:true)
        let readback = try stored()
        try Data(readback.message).write(to:directory.appendingPathComponent("slot-\(slot)-test-readback.syx"),options:.atomic)
        guard readback.payload == test.payload else { throw MIDIError.message("Stored test payload mismatch") }
        record("PASS stored renamed preset in slot \(slot); independent readback matches all 1024 bytes")
        try write(original,persistent:true)
        let final = try stored()
        try Data(final.message).write(to:directory.appendingPathComponent("slot-\(slot)-restored.syx"),options:.atomic)
        guard final.payload == original.payload else { throw MIDIError.message("Restored slot mismatch") }
        if try buffer().payload != edit.payload { try write(edit,persistent:false) }
        let finalBuffer = try buffer()
        try Data(finalBuffer.message).write(to:directory.appendingPathComponent("edit-buffer-restored.syx"),options:.atomic)
        guard finalBuffer.payload == edit.payload else { throw MIDIError.message("Restored edit buffer mismatch") }
        restored = true
        record("PASS slot \(slot) and original edit buffer restored byte-for-byte. No other stored slots written.")
    }
}
