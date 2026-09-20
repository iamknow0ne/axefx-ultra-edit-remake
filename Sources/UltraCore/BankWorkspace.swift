import Foundation

/// Local numbered slots. A missing slot is never silently filled or exported.
public struct BankWorkspace: Codable {
    public private(set) var slots: [Int: [UInt8]] = [:]
    public init() {}
    public init(presets: [UltraPreset]) throws {
        for preset in presets {
            guard let slot = preset.storedSlot, slots[slot] == nil else { throw MIDIError.message("Bank files must contain unique numbered stored presets.") }
            slots[slot] = preset.message
        }
    }
    public func preset(_ slot: Int) -> UltraPreset? { slots[slot].flatMap { try? UltraPreset(message:$0) } }
    public mutating func put(_ preset: UltraPreset, at slot: Int) throws { slots[slot] = try preset.forStorage(slot:slot) }
    public mutating func rename(_ slot: Int, name: String) throws {
        guard let preset = preset(slot) else { throw MIDIError.message("Choose an occupied slot.") }
        try put(preset.renamed(name),at:slot)
    }
    public mutating func transfer(from: Int, to: Int, copy: Bool = false, swap: Bool = false) throws {
        guard (0..<384).contains(from), (0..<384).contains(to), let source = preset(from) else { throw MIDIError.message("Choose a source and destination between 0 and 383.") }
        guard from != to else { return }
        if copy { try put(source,at:to); return }
        if swap {
            let target = preset(to); try put(source,at:to)
            if let target { try put(target,at:from) } else { slots.removeValue(forKey:from) }
            return
        }
        // Insertion moves intermediate slots, including empty positions.
        let direction = from < to ? 1 : -1
        var index = from
        while index != to {
            if let next = preset(index+direction) { try put(next,at:index) } else { slots.removeValue(forKey:index) }
            index += direction
        }
        try put(source,at:to)
    }
    public func export(banks: [Int]) throws -> Data {
        guard !banks.isEmpty, Set(banks).count == banks.count, banks.allSatisfy({ (0...2).contains($0) }) else { throw MIDIError.message("Choose bank A, B, C or all banks.") }
        var result = Data()
        for bank in banks {
            var payload: [UInt8] = []
            for slot in (bank*128)..<(bank*128+128) {
                guard let preset = preset(slot) else { throw MIDIError.message("Slot \(slot) is missing. Read or import the complete bank before exporting.") }
                payload += preset.payload
            }
            var message = UltraProtocol.modernHeader
            message += [4,UInt8(bank+2),0,0]
            for byte in payload { message += UltraProtocol.nibbles(Int(byte)) }
            message += UltraProtocol.nibbles(Int(payload.reduce(0,^)))
            message.append(0xF7)
            result.append(contentsOf:message)
        }
        return result
    }
}

public extension ParameterDefinition {
    /// Inverse of the catalog's estimated display mapping, not a device calibration.
    func rawValue(for value: Double, estimatedUnits: Bool) throws -> Int {
        guard value.isFinite else { throw MIDIError.message("Enter a finite number.") }
        if !estimatedUnits || kind == "INT" {
            guard value.rounded() == value, value >= Double(rawMinimum), value <= Double(rawMaximum) else { throw MIDIError.message("Enter a whole raw value from \(rawMinimum) to \(rawMaximum).") }
            return Int(value)
        }
        guard maximum > minimum, value >= minimum, value <= maximum else { throw MIDIError.message("Enter a value from \(minimum) to \(maximum).") }
        let fraction = kind == "LOG" && minimum > 0 ? log(value/minimum)/log(maximum/minimum) : (value-minimum)/(maximum-minimum)
        return max(rawMinimum,min(rawMaximum,Int((fraction*254).rounded())))
    }
}
