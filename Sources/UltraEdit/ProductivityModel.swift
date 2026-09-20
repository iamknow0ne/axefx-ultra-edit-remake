import AppKit
import UltraCore
import UniformTypeIdentifiers

extension EditorModel {
    var canEditDraft: Bool { draftMode && currentPreset != nil }
    var hasUndo: Bool { draftMode ? !draftUndo.isEmpty : canOperate && (!undoValues.isEmpty || modelUndo != nil || !gridUndo.isEmpty) }
    var hasRedo: Bool { draftMode ? !draftRedo.isEmpty : canEditGrid && !gridRedo.isEmpty }
    func redoChange() { if draftMode { redoDraft() } else { redoGrid() } }
    func loadProductivity() {
        do {
            if FileManager.default.fileExists(atPath:archiveURL("draft").path) { recoveredDraft = try WorkspaceFile.load(SavedPreset.self,from:archiveURL("draft")); guard recoveredDraft?.preset != nil else { throw MIDIError.message("The recovered draft is corrupt.") } }
            if FileManager.default.fileExists(atPath:archiveURL("effect-settings").path) { effectSettings = try WorkspaceFile.load([EffectSetting].self,from:archiveURL("effect-settings")) }
            if FileManager.default.fileExists(atPath:archiveURL("setlist").path) { setlist = try WorkspaceFile.load(PerformanceSetlist.self,from:archiveURL("setlist")); try setlist.validate() }
        } catch { toolsWritable = false; workspaceError = "Workspace could not be read and will not be overwritten: " + error.localizedDescription }
    }
    func persistTools() {
        do {
            guard toolsWritable else { throw MIDIError.message(workspaceError ?? "Workspace is protected after a read failure.") }
            try setlist.validate()
            try WorkspaceFile.save(effectSettings,to:archiveURL("effect-settings"))
            try WorkspaceFile.save(setlist,to:archiveURL("setlist"))
        } catch { fail(error) }
    }
    func withFreshPreset(_ action: @escaping (UltraPreset)->Void) {
        guard liveKey == nil, busy == 0 else { return }
        if draftMode || inspectedLibrary != nil { if let preset = currentPreset { action(preset) }; return }
        guard canOperate else { return }
        fetchPreset { [weak self] result in do { let preset = try result.get(); self?.apply(preset); action(preset) } catch { self?.fail(error) } }
    }
    func beginDraft() {
        withFreshPreset { [weak self] preset in
            guard let self else { return }
            do {
                try self.saveDraft(preset)
                self.draftMode = true; self.draftUndo = []; self.draftRedo = []
                self.apply(preset); self.status = "Offline draft • changes are saved locally; hardware stays unchanged"
            } catch { self.fail(error) }
        }
    }
    func resumeDraft() {
        guard liveKey == nil, busy == 0, let preset = recoveredDraft?.preset else { return }
        draftMode = true; draftUndo = []; draftRedo = []; apply(preset); status = "Recovered offline draft"
    }
    func finishDraft() {
        guard draftMode else { return }
        draftMode = false; draftUndo = []; draftRedo = []; inspectedLibrary = nil
        if connected { refreshPreset() }
        else { currentPreset = nil; cells = []; values = [:]; presetName = "No preset loaded"; status = "Draft saved for recovery • open a preset or reconnect" }
    }
    func saveDraft(_ preset: UltraPreset) throws {
        guard toolsWritable else { throw MIDIError.message(workspaceError ?? "Cannot save draft.") }
        let entry = SavedPreset(preset:preset,source:"Offline draft")
        try WorkspaceFile.save(entry,to:archiveURL("draft")); recoveredDraft = entry
    }
    func commitDraft(_ preset: UltraPreset) throws {
        guard draftMode, let old = currentPreset, old.payload != preset.payload else { return }
        try saveDraft(preset)
        draftUndo.append(old); if draftUndo.count > 100 { draftUndo.removeFirst() }; draftRedo = []
        apply(preset); status = "Draft saved locally • \(draftUndo.count) change(s) available to undo"
    }
    func editDraft(_ parameter: ParameterDefinition, raw: Int) {
        do { if let preset = currentPreset { try commitDraft(preset.settingParameter(effect:selectedEffect,parameter:parameter.id,raw:raw,catalog:catalog!)) } } catch { fail(error) }
    }
    func undoDraft() {
        guard draftMode, let old = draftUndo.last, let current = currentPreset else { return }
        do { try saveDraft(old); draftUndo.removeLast(); draftRedo.append(current); apply(old); status = "Draft change undone" } catch { fail(error) }
    }
    func redoDraft() {
        guard draftMode, let next = draftRedo.last, let current = currentPreset else { return }
        do { try saveDraft(next); draftRedo.removeLast(); draftUndo.append(current); apply(next); status = "Draft change redone" } catch { fail(error) }
    }
    func saveDraftCopy() {
        guard draftMode, let preset = currentPreset else { return }
        saveFile(Data(preset.message),name:preset.name + "-draft.syx")
    }
    func saveEffectSetting() {
        let effect = selectedEffect, title = effectSettingTitle.trimmingCharacters(in:.whitespacesAndNewlines)
        withFreshPreset { [weak self] preset in
            guard let self, let catalog = self.catalog else { return }
            do {
                let setting = try EffectSetting(preset:preset,effect:effect,title:title.isEmpty ? catalog.name(effect)+" · "+preset.name : title,catalog:catalog)
                self.effectSettings.insert(setting,at:0); self.persistTools(); self.effectSettingTitle = ""; self.status = "Effect setting saved • parameter values only"
            } catch { self.fail(error) }
        }
    }
    func applyEffectSetting(_ setting: EffectSetting) {
        let effect = selectedEffect
        withFreshPreset { [weak self] original in
            guard let self, let catalog = self.catalog else { return }
            do {
                let edited = try original.applying(setting,to:effect,catalog:catalog)
                if self.draftMode { try self.commitDraft(edited) }
                else if self.canEdit { self.restoreVerified(edited,original:original) }
                else { throw MIDIError.message("Start an offline draft to paste settings into a library preset.") }
            } catch { self.fail(error) }
        }
    }
    func removeEffectSetting(_ id: UUID) { effectSettings.removeAll { $0.id == id }; persistTools() }
    func addSong() {
        withFreshPreset { [weak self] preset in
            guard let self else { return }
            guard self.setlist.items.count < 512 else { self.fail(MIDIError.message("A setlist supports up to 512 entries.")); return }
            let song = SetlistItem(preset:preset); self.setlist.items.append(song); self.selectedSong = song.id; self.songNotes = ""; self.persistTools()
        }
    }
    func selectSong(_ item: SetlistItem) { selectedSong = item.id; songNotes = item.notes }
    func saveSongNotes() { if let index = setlist.items.firstIndex(where:{$0.id == selectedSong}) { setlist.items[index].notes = songNotes; persistTools() } }
    func moveSong(_ delta: Int) { if let id = selectedSong { setlist.move(id,by:delta); persistTools() } }
    func removeSong() { setlist.items.removeAll { $0.id == selectedSong }; selectedSong = nil; songNotes = ""; persistTools() }
    func loadSong() {
        guard !draftMode, connected, busy == 0, liveKey == nil, let preset = setlist.items.first(where:{$0.id == selectedSong})?.preset else { return }
        restoreVerified(preset)
    }
    func exportSetlist() {
        do { try setlist.validate(); let encoder = JSONEncoder(); encoder.outputFormatting = [.prettyPrinted,.sortedKeys]; saveFile(try encoder.encode(setlist),name:setlist.title+".ultraset") } catch { fail(error) }
    }
    func importSetlist() {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [UTType(filenameExtension:"ultraset") ?? .data]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let incoming = try WorkspaceFile.load(PerformanceSetlist.self,from:url); try incoming.validate()
            // Keep the previous setlist locally before replacing it.
            guard toolsWritable else { throw MIDIError.message("Workspace is protected after a read failure.") }
            try WorkspaceFile.save(setlist,to:archiveURL("setlist-before-import-\(Int(Date().timeIntervalSince1970))"))
            setlist = incoming; selectedSong = nil; songNotes = ""; persistTools()
        } catch { fail(error) }
    }
    func exportRigSheet() {
        withFreshPreset { [weak self] preset in
            guard let self, let catalog = self.catalog else { return }
            self.saveFile(Data(preset.rigSheet(catalog:catalog).utf8),name:preset.name+"-rig.md")
        }
    }
}
