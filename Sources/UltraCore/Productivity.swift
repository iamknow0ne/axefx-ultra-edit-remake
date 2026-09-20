import Foundation

public extension UltraPreset {
    func replacingPayload(_ data: [UInt8]) throws -> UltraPreset {
        guard data.count == 1024 else { throw MIDIError.message("A preset must contain exactly 1024 bytes.") }
        return try UltraPreset(message:Array(message.prefix(9)) + data.flatMap { UltraProtocol.nibbles(Int($0)) } + UltraProtocol.nibbles(Int(data.reduce(0,^))) + [0xF7])
    }
    func parameterRange(effect: Int) -> Range<Int>? {
        var offset = 130, seen = Set<Int>()
        while offset + 2 <= payload.count {
            let id = Int(payload[offset]), count = Int(payload[offset+1])
            guard (100...168).contains(id), count > 0, offset+2+count <= payload.count, seen.insert(id).inserted else { return nil }
            if id == effect { return (offset+2)..<(offset+2+count) }
            offset += 2+count
        }
        return nil
    }
    func settingParameter(effect: Int, parameter: Int, raw: Int, catalog: Catalog) throws -> UltraPreset {
        guard ![139,140,141].contains(effect), let definition = catalog.effect(effect),
              parameter != definition.typeParameterID,
              let control = definition.parameters.first(where:{$0.id == parameter}),
              !control.name.lowercased().hasPrefix("spare"),
              (control.rawMinimum...control.rawMaximum).contains(raw),
              let range = parameterRange(effect:effect), (0..<range.count).contains(parameter) else {
            throw MIDIError.message("This control cannot be safely edited offline. Change models on the Ultra, or paste a complete compatible effect setting.")
        }
        var data = payload; data[range.lowerBound+parameter] = UInt8(raw)
        return try replacingPayload(data)
    }
    func applying(_ setting: EffectSetting, to effect: Int, catalog: Catalog) throws -> UltraPreset {
        guard ![139,140,141].contains(effect), let family = catalog.effect(effect), family.id == setting.family,
              let range = parameterRange(effect:effect), range.count == setting.parameters.count,
              setting.parameters.allSatisfy({$0 <= 254}) else {
            throw MIDIError.message("Choose an existing effect of the same family and parameter layout. Modifiers and routing are kept from the destination.")
        }
        var data = payload; data.replaceSubrange(range,with:setting.parameters)
        return try replacingPayload(data)
    }
    func rigSheet(catalog: Catalog) -> String {
        var lines = ["# \(name)", "", "Axe-Fx Ultra rig sheet", "", "Payload SHA-256: `\(fingerprint)`", "", "Numeric values marked ≈ are catalog estimates; raw bytes are exact. Modifier/internal data stays in the companion .syx preset, not this sheet.", "", "## Signal path", ""]
        for row in 0..<4 {
            let route = cells.filter { $0.row == row && $0.effect != 0 }.map { "C\($0.column+1): \(catalog.name($0.effect)) [inputs \($0.inputMask)]" }.joined(separator:" → ")
            lines.append("- Row \(row+1): \(route.isEmpty ? "Empty" : route)")
        }
        for effect in effectParameters.keys.sorted() {
            lines += ["", "## \(catalog.name(effect))", "", "| Control | Value | Raw |", "| --- | --- | --- |"]
            for (id,raw) in (effectParameters[effect] ?? []).enumerated() {
                let p = catalog.effect(effect)?.parameters.first { $0.id == id }
                let label = (p?.name ?? "Parameter \(id)").replacingOccurrences(of:"|",with:"/")
                let display = (p.map { ($0.kind == "INT" ? "" : "≈ ") + $0.estimate(Int(raw)) } ?? "Unknown").replacingOccurrences(of:"|",with:"/")
                lines.append("| \(label) | \(display) | \(raw) |")
            }
        }
        return lines.joined(separator:"\n") + "\n"
    }
}

public struct EffectSetting: Codable, Identifiable {
    public let id: UUID
    public var title: String
    public let family: String
    public let parameters: [UInt8]
    public let source: String
    public init(preset: UltraPreset, effect: Int, title: String, catalog: Catalog) throws {
        guard ![139,140,141].contains(effect), let definition = catalog.effect(effect), let values = preset.effectParameters[effect] else { throw MIDIError.message("Select an effect present in this preset.") }
        id = UUID(); self.title = title; family = definition.id; parameters = values; source = preset.name
    }
}

public struct SetlistItem: Codable, Identifiable {
    public let id: UUID
    public var title: String
    public var notes: String
    public let message: [UInt8]
    public init(preset: UltraPreset, title: String? = nil, notes: String = "") {
        id = UUID(); self.title = title ?? preset.name; self.notes = notes; message = preset.message
    }
    public var preset: UltraPreset? { try? UltraPreset(message:message) }
}
public struct PerformanceSetlist: Codable {
    public var title: String = "My setlist"
    public var items: [SetlistItem] = []
    public init() {}
    public func validate() throws {
        guard items.count <= 512, Set(items.map(\.id)).count == items.count,
              items.allSatisfy({ $0.preset != nil }) else { throw MIDIError.message("Invalid setlist: duplicate entries, corrupt presets, or more than 512 songs.") }
    }
    public mutating func move(_ id: UUID, by delta: Int) {
        guard let index = items.firstIndex(where:{$0.id == id}), items.indices.contains(index+delta) else { return }
        items.swapAt(index,index+delta)
    }
}
public enum WorkspaceFile {
    public static func load<T: Decodable>(_ type: T.Type, from url: URL) throws -> T {
        let data = try Data(contentsOf:url)
        guard data.count <= 32*1024*1024 else { throw MIDIError.message("Workspace file exceeds 32 MB.") }
        return try JSONDecoder().decode(type,from:data)
    }
    public static func save<T: Encodable>(_ value: T, to url: URL) throws {
        try FileManager.default.createDirectory(at:url.deletingLastPathComponent(),withIntermediateDirectories:true)
        let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted,.sortedKeys]
        try encoder.encode(value).write(to:url,options:.atomic)
    }
}
