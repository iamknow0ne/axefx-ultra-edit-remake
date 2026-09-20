import Foundation
import UltraCore

struct ModifierSetting: Codable, Identifiable {
    var id = UUID()
    var title: String
    var fields: [Int:Int]
    func validate() throws {
        guard Set(fields.keys) == Set([0,1,2,3,4,5,10,11,12]), fields.values.allSatisfy({ (0...254).contains($0) }) else { throw MIDIError.message("Modifier setting is incomplete or invalid.") }
    }
}
struct ModifierAssignment: Identifiable {
    let effect: Int
    let parameter: ParameterDefinition
    let source: Int
    var id: String { "\(effect):\(parameter.id)" }
}
extension EditorModel {
    func loadModifierSettings() {
        do {
            if FileManager.default.fileExists(atPath:archiveURL("modifier-settings").path) {
                let items = try WorkspaceFile.load([ModifierSetting].self,from:archiveURL("modifier-settings"))
                try items.forEach { try $0.validate() }; modifierSettings = items
            }
        } catch { toolsWritable = false; workspaceError = error.localizedDescription }
    }
    func saveModifierSetting(_ name: String) {
        do {
            guard toolsWritable, busy == 0 else { throw MIDIError.message("Wait for a complete modifier read.") }
            let setting = ModifierSetting(title:name.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty ? "Modifier · \(modifierTarget?.name ?? "Shape")" : name,fields:modifierValues.mapValues { $0.0 })
            try setting.validate()
            var next = modifierSettings; next.append(setting)
            try WorkspaceFile.save(next,to:archiveURL("modifier-settings")); modifierSettings = next; status = "Modifier preset saved locally"
        } catch { fail(error) }
    }
    func modifierField(effect: Int, parameter: ParameterDefinition, field: Int, value: Int?, completion: @escaping (Result<Int,Error>)->Void) {
        do {
            request(try UltraProtocol.modifier(effect:effect,parameter:parameter.modifierID,modifier:field,value:value,header:header),match:{ b in
                b.count >= 16 && b[5] == 7 && b[6..<14].allSatisfy({ $0 < 16 }) && UltraProtocol.byte(b[6],b[7]) == effect && UltraProtocol.byte(b[8],b[9]) == parameter.modifierID && UltraProtocol.byte(b[10],b[11]) == field
            }) { result in completion(result.flatMap { bytes in
                Result { guard bytes[bytes.count-2] == 0 else { throw MIDIError.message("Malformed modifier reply") }; return UltraProtocol.byte(bytes[12],bytes[13]) }
            }) }
        } catch { completion(.failure(error)) }
    }
    func readModifierOverview() {
        guard canOperate, let preset = currentPreset, let catalog else { return }
        let targets = preset.effectParameters.keys.sorted().filter { ![139,140,141].contains($0) }.flatMap { effect in
            (catalog.effect(effect)?.parameters ?? []).filter { $0.modifierID > 0 && $0.id < (preset.effectParameters[effect]?.count ?? 0) }.map { (effect,$0) }
        }
        modifierAssignments = []; modifierScanning = true
        let token = UUID(); modifierScanToken = token
        func next(_ index: Int) {
            guard self.connected, self.modifierScanToken == token else { return }
            guard index < targets.count else { self.modifierScanning = false; self.status = "Read \(targets.count) modifier sources"; return }
            let (effect,p) = targets[index]
            self.modifierField(effect:effect,parameter:p,field:0,value:nil) { result in
                guard self.modifierScanToken == token else { return }
                do { let value = try result.get(); self.modifierAssignments.append(.init(effect:effect,parameter:p,source:value)); DispatchQueue.main.async { next(index+1) } }
                catch { self.modifierScanning = false; self.fail(error) }
            }
        }
        next(0)
    }
    func stopModifierScan() { modifierScanToken = UUID(); modifierScanning = false }
    func applyModifierSetting(_ setting: ModifierSetting) {
        guard canOperate, let parameter = modifierTarget else { return }
        let effect = selectedEffect
        do { try setting.validate() } catch { fail(error); return }
        fetchPreset { [weak self] result in
            guard let self else { return }
            do {
                let before = try result.get()
                self.snapshots.insert(SavedPreset(preset:before,title:"Before modifier preset",source:"Recovery"),at:0); try self.saveArchive(self.snapshots,name:"snapshots")
                let fields = setting.fields[0] == 0 ? [0] : [0,1,2,3,4,5,10,11,12]
                self.modifierApplying = true
                func next(_ index: Int) {
                    guard self.connected else { self.modifierApplying = false; return }
                    guard index < fields.count else {
                        self.modifierApplying = false
                        self.fetchPreset { result in
                            do { let after = try result.get(); self.apply(after); self.selectedEffect = effect; self.rememberLive(before:before,after:after); self.dirty = true; self.status = "Modifier preset applied • every field read back" }
                            catch { self.fail(error) }
                        }
                        return
                    }
                    let field = fields[index], value = setting.fields[field]!
                    self.modifierField(effect:effect,parameter:parameter,field:field,value:value) { result in
                        do {
                            let accepted = try result.get()
                            guard accepted == value else { throw MIDIError.message("Modifier field \(field) was clamped. Recovery snapshot retained.") }
                            self.modifierField(effect:effect,parameter:parameter,field:field,value:nil) { result in
                                do {
                                    let actual = try result.get(); guard actual == value else { throw MIDIError.message("Modifier field \(field) did not persist. Recovery snapshot retained.") }
                                    self.modifierValues[field] = (actual,""); next(index+1)
                                } catch { self.modifierApplying = false; self.fail(error) }
                            }
                        } catch { self.modifierApplying = false; self.fail(error) }
                    }
                }
                next(0)
            } catch { self.fail(error) }
        }
    }
}
