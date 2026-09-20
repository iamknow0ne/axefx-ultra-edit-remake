import Foundation

public extension UltraProtocol {
    /// The original recallPreset routine masks the low address to four bits
    /// in every bank. Reading a stored slot does not recall it into the DSP.
    static func storedPreset(_ slot: Int, header: [UInt8] = modernHeader) throws -> [UInt8] {
        guard (0..<384).contains(slot) else { throw MIDIError.message("Preset slot must be 0–383.") }
        return header + [3,0,UInt8(slot & 15),UInt8(slot >> 4),0xF7]
    }
}
public extension UltraPreset {
    var storedSlot: Int? {
        guard !isEditBuffer else { return nil }
        let slot = Int(message[7]) | (Int(message[8]) << 4)
        return (0..<384).contains(slot) ? slot : nil
    }
}

public extension UltraPreset {
    /// Firmware 11 returns the right bank-C payload but truncates the echoed
    /// address to eight bits. Verified against a separate complete bank-C dump.
    /// Use only for the single outstanding, explicitly addressed stored read.
    static func storedReply(_ bytes: [UInt8], requestedSlot slot: Int) throws -> UltraPreset {
        guard (0..<384).contains(slot) else { throw MIDIError.message("Preset slot must be 0–383.") }
        let preset = try UltraPreset(message:bytes)
        guard preset.storedSlot == slot || (slot >= 256 && preset.storedSlot == (slot & 255)) else { throw MIDIError.message("Reply belongs to a different preset slot.") }
        var message = bytes
        message[7] = UInt8(slot & 15); message[8] = UInt8(slot >> 4)
        return try UltraPreset(message:message)
    }
}
