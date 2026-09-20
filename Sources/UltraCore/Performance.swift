import Foundation

public struct TunerReading: Equatable {
    public let note: Int
    public let string: Int
    public let cents: Int
    public var noteName: String { ["C","C♯","D","E♭","E","F","F♯","G","A♭","A","B♭","B"][note] }
    /// Gen-1 function 0D: note, string, pitch deviation biased by 63.
    /// Recovered from AxeFxMIDIProtocol::getTunerInfo and TunerDisplayComponent.
    public init?(message: [UInt8]) {
        guard UltraProtocol.validEnvelope(message), message.count == 10, message[5] == 0x0D, message[6] < 12, message[7] < 6 else { return nil }
        note = Int(message[6]); string = Int(message[7]); cents = Int(message[8])-63
    }
}
public extension UltraProtocol {
    static func controller(_ cc: Int, value: Int, channel: Int) throws -> [UInt8] {
        guard (0..<128).contains(cc), (0..<128).contains(value), (1...16).contains(channel) else { throw MIDIError.message("MIDI controller/channel outside range") }
        return [UInt8(0xB0+channel-1),UInt8(cc),UInt8(value)]
    }

}

/// Gen-1 CAB_IR: 1024 signed Q1.31 coefficients, little endian, nibble encoding.
/// Coefficient scale and length recovered from loadUserCabIRs; transfer from storeCab.
public struct UserCabIR {
    public let samples: [Double]
    public init(samples: [Double], sampleRate: Int) throws {
        guard sampleRate == 48000, samples.count == 1024, samples.allSatisfy({ $0.isFinite && $0 >= -1 && $0 < 1 }) else { throw MIDIError.message("Ultra user cabs require exactly 1024 finite samples at 48 kHz, each in −1..<1. Lower the gain before encoding.") }
        self.samples = samples
    }
    public init(message: [UInt8]) throws {
        guard UltraProtocol.validEnvelope(message), message.count == 8204, message[5] == 10, message[6] < 10, message[9..<8203].allSatisfy({ $0 < 16 }) else { throw MIDIError.message("Not a Gen-1 Ultra user cabinet (8204 bytes).") }
        let bytes = stride(from:9,to:8201,by:2).map { UInt8(UltraProtocol.byte(message[$0],message[$0+1])) }
        guard bytes.reduce(0,^) == UInt8(UltraProtocol.byte(message[8201],message[8202])) else { throw MIDIError.message("Cabinet checksum failed.") }
        samples = stride(from:0,to:4096,by:4).map { i in
            let bits = UInt32(bytes[i]) | UInt32(bytes[i+1])<<8 | UInt32(bytes[i+2])<<16 | UInt32(bytes[i+3])<<24
            return Double(Int32(bitPattern:bits))/2147483648.0
        }
    }
    public func message(slot: Int, header: [UInt8] = UltraProtocol.modernHeader) throws -> [UInt8] {
        guard (1...10).contains(slot) else { throw MIDIError.message("User Cab slots are 1–10.") }
        var bytes: [UInt8] = []
        for sample in samples {
            let value = Int32(max(-2147483648,min(2147483647,(Double(sample)*2147483648).rounded())))
            let bits = UInt32(bitPattern:value)
            for shift in [0,8,16,24] { bytes.append(UInt8((bits>>shift)&255)) }
        }
        var result = header + [10,UInt8(slot-1),0,0]
        for byte in bytes { result += UltraProtocol.nibbles(Int(byte)) }
        result += UltraProtocol.nibbles(Int(bytes.reduce(0,^))); result.append(0xF7)
        return result
    }
}
