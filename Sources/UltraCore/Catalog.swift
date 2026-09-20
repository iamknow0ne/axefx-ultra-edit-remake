import Foundation
public struct Catalog: Codable {
    public let schemaVersion: Int
    public let source: String
    public let effects: [EffectDefinition]
    public init(url: URL) throws { self = try JSONDecoder().decode(Catalog.self, from: Data(contentsOf: url)) }
    public func effect(_ id: Int) -> EffectDefinition? { effects.first { $0.instances.contains { $0.id == id } } }
    public func name(_ id: Int) -> String { if id == 0 { return "Empty" }; if id >= 200 && id <= 247 { return "Shunt" }; return effect(id)?.instances.first { $0.id == id }?.name ?? "Block \(id)" }
}
public struct EffectDefinition: Codable, Identifiable {
    public let id: String
    public let name: String
    public let instances: [EffectInstance]
    public let typeParameterID: Int?
    public let parameters: [ParameterDefinition]
}
public struct EffectInstance: Codable, Identifiable { public let id: Int; public let name: String }
public struct ParameterDefinition: Codable, Identifiable {
    public let id: Int
    public let name: String
    public let key: String
    public let page: String
    public let order: Int
    public let kind: String
    public let minimum: Double
    public let maximum: Double
    public let precision: Int
    public let unit: String
    public let defaultValue: Int
    public let choices: [String]
    public let modifierID: Int
    public let switches: [ParameterSwitch]
    public var rawMinimum: Int { kind == "INT" ? max(0, min(254, Int(minimum))) : 0 }
    public var rawMaximum: Int { kind == "INT" ? max(rawMinimum, min(254, Int(maximum))) : 254 }
    public func estimate(_ raw: Int) -> String {
        if kind == "INT", choices.indices.contains(raw - rawMinimum) { return choices[raw - rawMinimum] }
        if kind == "INT" { return String(raw) + (unit.isEmpty ? "" : " " + unit) }
        if minimum == maximum { return "Raw \(raw)" }
        let fraction = Double(raw) / 254
        let value = kind == "LOG" && minimum > 0 && maximum > 0 ? minimum * pow(maximum / minimum, fraction) : minimum + (maximum - minimum) * fraction
        return String(format: "%.*f", min(precision,3), value) + (unit.isEmpty ? "" : " \(unit)")
    }
}

public struct ParameterSwitch: Codable { public let name: String; public let bit: Int }
