import Foundation

/// File-only compatibility. Live replies still require the connected Ultra's header.
public enum UltraImport {
    public static func gen1Message(_ bytes: [UInt8]) throws -> [UInt8] {
        guard bytes.count >= 7, bytes.first == 240, bytes.last == 247, bytes[1] == 0,
              ((bytes[2] == 1 && bytes[3] == 116) || bytes[2] == 0) else { throw MIDIError.message("Not a Fractal Gen-1 SysEx message.") }
        guard bytes[4] <= 1 else {
            let device = bytes[4] == 3 ? "Axe-Fx II" : "another Fractal generation (model \(bytes[4]))"
            throw MIDIError.message("This file targets \(device), not the Standard/Ultra. It cannot be loaded directly on the Ultra.")
        }
        var result = bytes; result[4] = 1
        guard UltraProtocol.validEnvelope(result) else { throw MIDIError.message("Invalid Gen-1 SysEx encoding.") }
        return result
    }
    public static func read(_ data: Data) throws -> (presets: [UltraPreset], cabinets: [UserCabIR]) {
        var framer = SysExFramer(); let messages = framer.feed(Array(data))
        guard !messages.isEmpty, messages.reduce(0,{ $0+$1.count }) == data.count else { throw MIDIError.message("File contains incomplete or non-SysEx data.") }
        var presets: [UltraPreset] = [], cabinets: [UserCabIR] = []
        for original in messages {
            let message = try gen1Message(original)
            if message[5] == 18 { throw MIDIError.message("This is an effect-block preset, not a complete tone. Gen-1 block-file import is not supported yet.") }
            if message[5] == 10 { cabinets.append(try UserCabIR.readFile(Data(message))) }
            else { presets += try UltraPreset.readFile(Data(message)) }
        }
        return (presets,cabinets)
    }
}

public extension UserCabIR {
    static func readFile(_ data: Data) throws -> UserCabIR {
        let message = try UltraImport.gen1Message(Array(data))
        guard message[5] == 10 else { throw MIDIError.message("This is a preset, not a cabinet impulse. Import it in the Library.") }
        if message.count == 8204 { return try UserCabIR(message:message) }
        guard message.count == 4108, message[6] < 10, message[9..<4107].allSatisfy({ $0 < 16 }) else { throw MIDIError.message("Choose a Gen-1 512- or 1024-sample cabinet .syx file.") }
        let bytes = stride(from:9,to:4105,by:2).map { UInt8(UltraProtocol.byte(message[$0],message[$0+1])) }
        guard bytes.reduce(0,^) == UInt8(UltraProtocol.byte(message[4105],message[4106])) else { throw MIDIError.message("Cabinet checksum failed.") }
        // Preserve the original 512 coefficients and append silence for the Ultra's 1024-sample buffer.
        let payload = bytes + Array(repeating:UInt8(0),count:2048)
        let expanded: [UInt8] = Array(message.prefix(9)) + payload.flatMap { UltraProtocol.nibbles(Int($0)) } + UltraProtocol.nibbles(Int(payload.reduce(0,^))) + [247]
        return try UserCabIR(message:expanded)
    }
}

public struct SavedCabinet: Codable, Identifiable {
    public let id: UUID
    public let title: String
    public let message: [UInt8]
    public init(cabinet: UserCabIR, title: String) throws {
        id = UUID(); self.title = title; message = try cabinet.message(slot:1)
    }
    public var cabinet: UserCabIR? { try? UserCabIR(message:message) }
}
