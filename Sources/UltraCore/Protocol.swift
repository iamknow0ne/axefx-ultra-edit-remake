import Foundation

public enum UltraProtocol {
    public static let modernHeader: [UInt8] = [0xF0, 0, 1, 0x74, 1]
    public static func header(legacy: Bool = false, legacyID: UInt8 = 125) -> [UInt8] { legacy ? [0xF0, 0, 0, legacyID & 127, 1] : modernHeader }
    public static func nibbles(_ value: Int) -> [UInt8] { [UInt8(value & 15), UInt8((value >> 4) & 15)] }
    public static func byte(_ lo: UInt8, _ hi: UInt8) -> Int { Int(lo) | Int(hi) << 4 }
    public static func firmware(header: [UInt8] = modernHeader) -> [UInt8] { header + [8, 0, 0, 0xF7] }
    public static func name(header: [UInt8] = modernHeader) -> [UInt8] { header + [15, 0xF7] }
    public static func patch(header: [UInt8] = modernHeader) -> [UInt8] { header + [3, 1, 0, 0, 0xF7] }
    public static func parameter(effect: Int, parameter: Int, value: Int? = nil, header: [UInt8] = modernHeader) throws -> [UInt8] {
        guard (0...255).contains(effect), (0...255).contains(parameter), value.map({ (0...254).contains($0) }) ?? true else { throw MIDIError.message("Parameter outside the Ultra's range.") }
        var result = header + [UInt8(2)]
        result += nibbles(effect); result += nibbles(parameter); result += nibbles(value ?? 0)
        result += [value == nil ? UInt8(0) : UInt8(1), 0xF7]; return result
    }
    public static func modifier(effect: Int, parameter: Int, modifier: Int, value: Int? = nil, header: [UInt8] = modernHeader) throws -> [UInt8] {
        guard (100...168).contains(effect), (1...255).contains(parameter), (0...12).contains(modifier), value.map({ (0...254).contains($0) }) ?? true else { throw MIDIError.message("Invalid modifier address or value.") }
        var result = header + [UInt8(7)]
        result += nibbles(effect); result += nibbles(parameter); result += nibbles(modifier); result += nibbles(value ?? 0)
        result += [value == nil ? UInt8(0) : UInt8(1), 0xF7]; return result
    }
    public static func rename(_ name: String, header: [UInt8] = modernHeader) throws -> [UInt8] {
        guard name.utf8.count <= 20, name.utf8.allSatisfy({ $0 >= 32 && $0 <= 126 }) else { throw MIDIError.message("Preset names use up to 20 plain ASCII characters.") }
        var result = header + [UInt8(9)]
        result += Array(name.utf8); result += Array(repeating: UInt8(32), count: 20 - name.utf8.count); result += [0,0,0,0xF7]; return result
    }
    public static func place(effect: Int, position: Int, header: [UInt8] = modernHeader) throws -> [UInt8] {
        guard (0...47).contains(position), effect == 0 || (100...168).contains(effect) || effect == 200 else { throw MIDIError.message("Invalid grid position or effect.") }
        return header + [5] + nibbles(effect) + [UInt8(position), 0xF7]
    }
    public static func connect(source: Int, destination: Int, enabled: Bool, header: [UInt8] = modernHeader) throws -> [UInt8] {
        guard (0...47).contains(source), (0...47).contains(destination), destination / 4 == source / 4 + 1 else { throw MIDIError.message("Connect blocks in adjacent grid columns.") }
        return header + [6, UInt8(source), UInt8(destination), enabled ? 1 : 0, 0xF7]
    }
    public static func program(_ number: Int, channel: Int) throws -> [[UInt8]] {
        guard (0...383).contains(number), (1...16).contains(channel) else { throw MIDIError.message("Preset must be 0–383; channel must be 1–16.") }
        return [[UInt8(0xB0 + channel - 1), 0, UInt8(number / 128)], [UInt8(0xC0 + channel - 1), UInt8(number % 128)]]
    }
    public static func validEnvelope(_ bytes: [UInt8]) -> Bool {
        bytes.count >= 7 && bytes.first == 0xF0 && bytes.last == 0xF7 && bytes[1] == 0 && bytes[4] == 1 && ((bytes[2] == 1 && bytes[3] == 0x74) || bytes[2] == 0) && bytes.dropFirst().dropLast().allSatisfy { $0 < 128 }
    }
    public static func status(_ bytes: [UInt8], for function: UInt8) -> Int? {
        guard validEnvelope(bytes) else { return nil }
        if bytes.count == 9 && bytes[5] == 0x0B && bytes[6] == function { return Int(bytes[7]) }
        if bytes.count == 8 && bytes[5] == function { return Int(bytes[6]) }
        return nil
    }
    public static func response(_ bytes: [UInt8]) -> ParameterValue? {
        guard validEnvelope(bytes), bytes[5] == 2, bytes.count >= 14, bytes[6..<12].allSatisfy({ $0 < 16 }), bytes[bytes.count-2] == 0 else { return nil }
        let raw = byte(bytes[10], bytes[11])
        guard raw <= 254 else { return nil }
        return ParameterValue(effect: byte(bytes[6],bytes[7]), parameter: byte(bytes[8],bytes[9]), raw: raw, text: String(bytes: bytes[12..<(bytes.count-2)], encoding: .ascii) ?? "")
    }
}
public struct ParameterValue: Equatable, Codable {
    public let effect: Int
    public let parameter: Int
    public let raw: Int
    public let text: String
    public init(effect: Int, parameter: Int, raw: Int, text: String) { self.effect = effect; self.parameter = parameter; self.raw = raw; self.text = text }
    public var key: String { "\(effect):\(parameter)" }
}

public struct GridCell: Identifiable, Equatable, Codable {
    public let id: Int
    public let effect: Int
    public let inputMask: Int
    public var row: Int { id % 4 }
    public var column: Int { id / 4 }
}

/// Gen-1 presets hold 1024 bytes nibble-encoded, followed by their XOR checksum.
/// The six transfer header bytes preceding the payload are not checksummed.
public struct UltraPreset {
    public let message: [UInt8]
    public let payload: [UInt8]
    public var isEditBuffer: Bool { message[6] == 1 }
    public var name: String { String(bytes: payload[2..<22].prefix(while: { $0 != 0 }), encoding: .ascii)?.trimmingCharacters(in: .whitespaces) ?? "Unnamed" }
    public var cells: [GridCell] { (0..<48).map { GridCell(id: $0, effect: Int(payload[34 + $0*2]), inputMask: Int(payload[35 + $0*2])) } }
    /// Gen-1 payload records: effect ID, byte count, contiguous parameter bytes.
    /// Stop at the zero terminator; remaining modifier/opaque data is untouched.
    public var effectParameters: [Int: [UInt8]] {
        var result: [Int: [UInt8]] = [:]
        var offset = 130
        while offset + 2 <= payload.count {
            let effect = Int(payload[offset]), count = Int(payload[offset+1])
            guard (100...168).contains(effect), count > 0, offset + 2 + count <= payload.count, result[effect] == nil else { break }
            result[effect] = Array(payload[(offset+2)..<(offset+2+count)])
            offset += 2 + count
        }
        return result
    }
    public init(message: [UInt8]) throws {
        guard UltraProtocol.validEnvelope(message), message[5] == 4, message.count == 2060, message[6] <= 1,
              message[9..<2059].allSatisfy({ $0 < 16 }) else { throw MIDIError.message("Not a complete Axe-Fx Ultra preset (2060 bytes).") }
        let payload = stride(from: 9, to: 2057, by: 2).map { UInt8(UltraProtocol.byte(message[$0],message[$0+1])) }
        let checksum = UInt8(UltraProtocol.byte(message[2057], message[2058]))
        guard payload.reduce(0, ^) == checksum else { throw MIDIError.message("Preset checksum failed. The MIDI transfer may be incomplete.") }
        self.message = message; self.payload = payload
    }
    public func renamed(_ name: String) throws -> UltraPreset {
        _ = try UltraProtocol.rename(name)
        var data = payload
        data.replaceSubrange(2..<22,with:Array(name.utf8)+Array(repeating:UInt8(32),count:20-name.utf8.count))
        var bytes = Array(message.prefix(9))
        bytes += data.flatMap { UltraProtocol.nibbles(Int($0)) }
        bytes += UltraProtocol.nibbles(Int(data.reduce(0,^))); bytes += [0xF7]
        return try UltraPreset(message:bytes)
    }
    public func forEditBuffer(header: [UInt8] = UltraProtocol.modernHeader) -> [UInt8] { header + [4,1,0,0] + Array(message[9...]) }
    public func forStorage(slot: Int, header: [UInt8] = UltraProtocol.modernHeader) throws -> [UInt8] {
        guard (0...383).contains(slot) else { throw MIDIError.message("Preset slot must be 0–383.") }
        // Match the original storePreset routine: bank C retains all seven
        // low bits; bits 4...6 overlap the following byte.
        return header + [4,0,UInt8(slot < 256 ? slot & 15 : slot & 127),UInt8(slot >> 4)] + Array(message[9...])
    }
    public static func readFile(_ data: Data) throws -> [UltraPreset] {
        var framer = SysExFramer()
        let messages = framer.feed(Array(data))
        guard !messages.isEmpty else { throw MIDIError.message("No complete SysEx messages in this file.") }
        var result: [UltraPreset] = []
        for message in messages {
            if message.count == 262156, UltraProtocol.validEnvelope(message), message[5] == 4, (2...4).contains(message[6]) {
                guard message[9..<262155].allSatisfy({ $0 < 16 }) else { throw MIDIError.message("Invalid bank encoding.") }
                let payload = stride(from: 9, to: 262153, by: 2).map { UInt8(UltraProtocol.byte(message[$0],message[$0+1])) }
                guard payload.reduce(0, ^) == UInt8(UltraProtocol.byte(message[262153],message[262154])) else { throw MIDIError.message("Bank checksum failed.") }
                for i in 0..<128 {
                    let bytes = Array(payload[(i*1024)..<((i+1)*1024)])
                    let encoded = bytes.flatMap { UltraProtocol.nibbles(Int($0)) }
                    let slot = (Int(message[6])-2)*128+i
                    let single = Array(message.prefix(5)) + [4,0,UInt8(slot & 15), UInt8(slot >> 4)] + encoded + UltraProtocol.nibbles(Int(bytes.reduce(0, ^))) + [0xF7]
                    result.append(try UltraPreset(message: single))
                }
            } else { result.append(try UltraPreset(message: message)) }
        }
        guard messages.reduce(0, { $0 + $1.count }) == data.count else { throw MIDIError.message("File contains incomplete or non-SysEx data.") }
        return result
    }
}
