import Foundation
import UltraCore

enum PerformanceVerification {
    static func run(transport: MIDITransport, directory: URL) throws {
        let queue = RequestQueue(sendLong:{ try transport.sendSysEx($0) },send:{ try transport.send($0) })
        var log: [String] = []
        func record(_ text: String) { print(text); fflush(stdout); log.append(text) }
        defer { try? Data(log.joined(separator:"\n").utf8).write(to:directory.appendingPathComponent("performance-verification.txt")) }
        transport.onMessage = { bytes in if UltraProtocol.validEnvelope(bytes), bytes[5] != 16 { queue.receive(bytes) } }
        func request(_ bytes: [UInt8], match: @escaping ([UInt8])->Bool) throws -> [UInt8] {
            var result: Result<[UInt8],Error>?
            queue.enqueue(.init(bytes:bytes,timeout:4,matches:match) { result = $0 })
            let end = Date().addingTimeInterval(8)
            while result == nil && Date() < end { RunLoop.main.run(until:Date().addingTimeInterval(0.005)) }
            guard let result else { queue.cancel(); throw MIDIError.message("Performance verification timed out") }; return try result.get()
        }
        func patch() throws -> UltraPreset { try UltraPreset(message:request(UltraProtocol.patch(),match: { $0.count == 2060 && $0[5] == 4 && $0[6] == 1 })) }
        func upload(_ preset: UltraPreset) throws {
            let ack = try request(preset.forEditBuffer(),match: { UltraProtocol.status($0,for:4) != nil })
            guard UltraProtocol.status(ack,for:4) == 1, try patch().payload == preset.payload else { throw MIDIError.message("Full preset readback mismatch") }
        }
        let before = try patch()
        try Data(before.message).write(to:directory.appendingPathComponent("before.syx"),options:.atomic)
        var complete = false
        defer {
            if !complete { queue.cancel(); do { try upload(before); record("RECOVERED original edit buffer") } catch { record("RECOVERY FAILED: \(error). Backup retained.") } }
        }
        for effect in [139,140,141] {
            guard let range = before.parameterRange(effect:effect) else { throw MIDIError.message("Global record missing") }
            let parameter = effect == 141 ? 1 : 0, offset = range.lowerBound+parameter
            var data = before.payload; data[offset] = data[offset] == 0 ? 1 : data[offset]-1
            let modified = try before.replacingPayload(data)
            try upload(modified)
            try Data(modified.message).write(to:directory.appendingPathComponent("global-\(effect)-verified.syx"))
            record("PASS global record \(effect), control \(parameter): changed one raw step via complete preset; 1024-byte readback")
            try upload(before)
        }
        let catalog = try Catalog(url:URL(fileURLWithPath:"Resources/UltraCatalog.json"))
        for effect in before.cells.map(\.effect).filter({ (100...138).contains($0) }) {
            guard let parameter = catalog.effect(effect)?.parameters.first(where:{ $0.key.hasSuffix("_BYPASS") || $0.key.hasSuffix("_FLAGS") }) else { continue }
            func flag(_ raw: Int? = nil) throws -> ParameterValue {
                let bytes = try request(UltraProtocol.parameter(effect:effect,parameter:parameter.id,value:raw),match:{ UltraProtocol.response($0)?.key == "\(effect):\(parameter.id)" })
                guard let value = UltraProtocol.response(bytes) else { throw MIDIError.message("Invalid bypass flags") }; return value
            }
            let old = try flag(), target = old.raw ^ 1
            record("Bypass \(effect) parameter \(parameter.id) original \(old.raw) \(old.text)")
            _ = try flag(target)
            guard try flag().raw == target else { throw MIDIError.message("Bypass readback mismatch") }
            let modified = try patch()
            guard let range = before.parameterRange(effect:effect) else { throw MIDIError.message("Missing block record") }
            var expected = before.payload; expected[range.lowerBound+parameter.id] = UInt8(target)
            guard modified.payload == expected else { throw MIDIError.message("Bypass changed unexpected bytes") }
            _ = try flag(old.raw)
            guard try flag().raw == old.raw, try patch().payload == before.payload else { throw MIDIError.message("Bypass restoration mismatch") }
            record("PASS bypass \(effect), bit 0 toggle and restore, all 1024 bytes independently read back")
        }
        try upload(before)
        let final = try patch(); try Data(final.message).write(to:directory.appendingPathComponent("after.syx"))
        guard final.payload == before.payload else { throw MIDIError.message("Final buffer mismatch") }
        complete = true; record("PASS original edit buffer restored byte-for-byte; no stored writes")
    }
}
