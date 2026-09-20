import Foundation
import CryptoKit

public struct PresetChange: Identifiable, Equatable {
    public let id: String
    public let section: String
    public let label: String
    public let before: String
    public let after: String
}

public extension UltraPreset {
    var fingerprint: String { SHA256.hash(data: Data(payload)).map { String(format: "%02x", $0) }.joined() }
    /// Compare decoded values while retaining an explicit count for unknown data.
    func changes(from previous: UltraPreset, catalog: Catalog) -> [PresetChange] {
        var result: [PresetChange] = []
        if name != previous.name { result.append(.init(id:"name",section:"Preset",label:"Name",before:previous.name,after:name)) }
        for (old,new) in zip(previous.cells,cells) where old != new {
            let describe: (GridCell) -> String = { cell in
                let rows = (0..<4).filter { cell.inputMask & (1 << $0) != 0 }.map { String($0+1) }.joined(separator:", ")
                return catalog.name(cell.effect) + (rows.isEmpty ? "" : " · input rows " + rows)
            }
            result.append(.init(id:"cell:\(new.id)",section:"Routing",label:"Row \(new.row+1), column \(new.column+1)",before:describe(old),after:describe(new)))
        }
        let oldRecords = previous.effectParameters, newRecords = effectParameters
        for effect in Set(oldRecords.keys).union(newRecords.keys).sorted() {
            let old = oldRecords[effect] ?? [], new = newRecords[effect] ?? []
            for index in 0..<max(old.count,new.count) {
                let a = old.indices.contains(index) ? Int(old[index]) : nil
                let b = new.indices.contains(index) ? Int(new[index]) : nil
                guard a != b else { continue }
                let parameter = catalog.effect(effect)?.parameters.first { $0.id == index }
                let describe: (Int?) -> String = { value in
                    guard let value else { return "Absent" }
                    if let parameter, parameter.kind == "INT", !parameter.choices.isEmpty { return parameter.estimate(value) + " [\(value)]" }
                    return "Raw \(value)"
                }
                result.append(.init(id:"\(effect):\(index)",section:catalog.name(effect),label:parameter?.name ?? "Parameter \(index)",before:describe(a),after:describe(b)))
            }
        }
        // Parameter records may move when blocks are added. Compare their opaque
        // tails as sequences, rather than assigning changed offsets false labels.
        func tail(_ preset: UltraPreset) -> [UInt8] {
            var offset = 130
            var seen = Set<Int>()
            while offset + 2 <= preset.payload.count {
                let effect = Int(preset.payload[offset]), count = Int(preset.payload[offset+1])
                guard (100...168).contains(effect), count > 0, offset+2+count <= preset.payload.count, !seen.contains(effect) else { break }
                seen.insert(effect); offset += 2+count
            }
            return Array(preset.payload[offset...])
        }
        let a = tail(previous), b = tail(self)
        let metadataOffsets = Array(0..<2) + Array(22..<34)
        let metadataChanges = metadataOffsets.filter { previous.payload[$0] != payload[$0] }.count
        if a != b || metadataChanges > 0 {
            result.append(.init(id:"opaque",section:"Additional preset data",label:"Modifiers / internal data",before:"Original data",after:"Changed · preserved in snapshot"))
        }
        // Includes name padding and any future unrecognized structure.
        if result.isEmpty && previous.payload != payload {
            result.append(.init(id:"other",section:"Additional preset data",label:"Unlabelled bytes",before:"Original data",after:"Changed · preserved in snapshot"))
        }
        return result
    }
}

public struct SavedPreset: Codable, Identifiable {
    public let id: UUID
    public var title: String
    public let created: Date
    public let source: String
    public var favorite: Bool
    public let message: [UInt8]
    public init(preset: UltraPreset, title: String? = nil, source: String, favorite: Bool = false) {
        id = UUID(); self.title = title ?? preset.name; created = Date(); self.source = source; self.favorite = favorite; message = preset.message
    }
    public var preset: UltraPreset? { try? UltraPreset(message:message) }
    public func matches(_ search: String, catalog: Catalog?) -> Bool {
        let query = search.trimmingCharacters(in:.whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        let effects = preset?.cells.filter { $0.effect != 0 }.map { catalog?.name($0.effect) ?? "" }.joined(separator:" ") ?? ""
        return [title,source,preset?.name ?? "",effects].joined(separator:" ").localizedCaseInsensitiveContains(query)
    }
}

public enum PresetArchive {
    public static func load(_ url: URL) throws -> [SavedPreset] {
        guard FileManager.default.fileExists(atPath:url.path) else { return [] }
        let entries = try JSONDecoder().decode([SavedPreset].self,from:Data(contentsOf:url))
        guard entries.allSatisfy({ $0.preset != nil }), Set(entries.map(\.id)).count == entries.count else { throw MIDIError.message("The local preset archive is damaged. Its original file has been preserved.") }
        return entries
    }
    public static func save(_ entries: [SavedPreset], to url: URL) throws {
        guard entries.allSatisfy({ $0.preset != nil }) else { throw MIDIError.message("Cannot save an invalid preset.") }
        try FileManager.default.createDirectory(at:url.deletingLastPathComponent(),withIntermediateDirectories:true)
        try JSONEncoder().encode(entries).write(to:url,options:.atomic)
    }
}
