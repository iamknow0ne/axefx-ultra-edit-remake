import UltraCore

extension EditorModel {
    var isPresetGlobal: Bool { [139,140,141].contains(selectedEffect) }
    func setPresetGlobal(_ parameter: ParameterDefinition, raw: Int) {
        guard isPresetGlobal, let catalog, (canOperate || canEditDraft) else { return }
        let effect = selectedEffect
        func change(_ before: UltraPreset) {
            do {
                let after = try before.settingPresetGlobal(effect:effect,parameter:parameter.id,raw:raw,catalog:catalog)
                if self.draftMode { try self.commitDraft(after); self.selectedEffect = effect }
                else { self.restoreVerified(after,original:before) { success in if success { self.selectedEffect = effect; self.status = "Preset global updated • full readback verified" } } }
            } catch { self.fail(error) }
        }
        if draftMode, let preset = currentPreset { change(preset) }
        else { fetchPreset { result in do { change(try result.get()) } catch { self.fail(error) } } }
    }
}
