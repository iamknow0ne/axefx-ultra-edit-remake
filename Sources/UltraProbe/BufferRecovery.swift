import Foundation
import UltraCore

enum BufferRecovery {
    static func run(transport: MIDITransport, url: URL, directory: URL, queryParameter: Int?) throws {
        let original = try UltraPreset(message:Array(Data(contentsOf:url)))
        try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
        var reply: [UInt8]?
        var log: [String] = []
        func record(_ s: String) { print(s); fflush(stdout); log.append(s) }
        transport.onMessage = { bytes in
            guard bytes.count > 6,bytes[5] != 0x10 else { return }
            record("RX \(bytes.count): " + bytes.prefix(24).map { String(format:"%02X",$0) }.joined(separator:" "))
            if bytes.count == 2060,bytes[5] == 4 { reply = bytes }
        }
        defer { try? Data(log.joined(separator:"\n").utf8).write(to:directory.appendingPathComponent("recovery-log.txt")) }
        record("Restore original edit buffer from \(url.lastPathComponent); no stored slot write")
        try transport.sendSysEx(original.forEditBuffer())
        RunLoop.main.run(until:Date().addingTimeInterval(2))
        func read(_ name: String) throws -> UltraPreset {
            reply = nil; try transport.send(UltraProtocol.patch())
            let end = Date().addingTimeInterval(4)
            while reply == nil && Date()<end { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
            guard let reply else { throw MIDIError.message("No preset readback after restoration") }
            try Data(reply).write(to:directory.appendingPathComponent(name))
            return try UltraPreset(message:reply)
        }
        let restored = try read("restored.syx")
        record("Restored payload matches original: \(restored.payload == original.payload)")
        guard restored.payload == original.payload else { throw MIDIError.message("Full edit buffer did not restore byte-exactly") }
        if let parameter = queryParameter {
            record("Diagnose query-only Amp 1 parameter \(parameter)")
            try transport.send(UltraProtocol.parameter(effect:106,parameter:parameter))
            RunLoop.main.run(until:Date().addingTimeInterval(0.5))
            let after = try read("after-query.syx")
            let differences = zip(restored.payload,after.payload).enumerated().filter { $0.element.0 != $0.element.1 }.map { "\($0.offset): \($0.element.0) → \($0.element.1)" }
            record("Query-only differences: " + differences.joined(separator:", "))
            if !differences.isEmpty {
                try transport.sendSysEx(original.forEditBuffer()); RunLoop.main.run(until:Date().addingTimeInterval(2))
                let final = try read("final-restored.syx")
                guard final.payload == original.payload else { throw MIDIError.message("Post-query recovery mismatch") }
                record("Original preset restored again, byte-exactly")
            }
        }
    }
}
