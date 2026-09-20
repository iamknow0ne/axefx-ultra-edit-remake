import Foundation
import UltraCore

extension EditorModel {
    var canActivateLibrary: Bool {
        connected && !connecting && !librarySwitching && !draftMode && busy == 0 && liveKey == nil && !readingDevice && !gridWorking && !modifierScanning && !modifierApplying
    }
    func visibleDeviceSlots(bank: Int) -> [Int] {
        let query = librarySearch.trimmingCharacters(in:.whitespacesAndNewlines)
        if let number = Int(query), (0..<384).contains(number) { return [number] }
        return (0..<384).filter { slot in
            (bank == -1 || slot / 128 == bank) && (query.isEmpty || devicePresets[slot]?.title.localizedCaseInsensitiveContains(query) == true)
        }
    }
    // Missing/filtered selection starts at the first (Next) or last (Previous) result.
    // At a visible boundary the buttons stop, rather than wrapping unexpectedly.
    func adjacentLibraryItem<T: Equatable>(_ items: [T], selected: T?, direction: Int) -> T? {
        guard !items.isEmpty, direction == -1 || direction == 1 else { return nil }
        guard let selected, let index = items.firstIndex(of:selected) else { return direction == 1 ? items.first : items.last }
        let next = index + direction
        return items.indices.contains(next) ? items[next] : nil
    }
    func navigateDeviceLibrary(_ direction: Int, bank: Int) {
        guard canActivateLibrary, let slot = adjacentLibraryItem(visibleDeviceSlots(bank:bank),selected:selectedLibrarySlot,direction:direction) else { return }
        activateDeviceSlot(slot)
    }
    func navigateMacLibrary(_ direction: Int) {
        guard canActivateLibrary, let id = adjacentLibraryItem(visibleLibrary.map(\.id),selected:selectedMacPreset,direction:direction), let entry = library.first(where:{ $0.id == id }) else { return }
        activateMacPreset(entry)
    }
    func previewMacPreset(_ entry: SavedPreset) {
        guard !librarySwitching, !draftMode, busy == 0, liveKey == nil else { return }
        selectedMacPreset = entry.id; inspect(entry)
    }
    func activateMacPreset(_ entry: SavedPreset) {
        guard canActivateLibrary, let preset = entry.preset else { return }
        selectedMacPreset = entry.id
        librarySwitching = true
        let token = UUID(); librarySwitchToken = token
        status = "Loading \(entry.title) • saving recovery snapshot…"
        restoreVerified(preset) { [weak self] success in
            guard let self, self.librarySwitchToken == token else { return }
            self.librarySwitching = false
            if success { self.status = "Loaded \(entry.title) • edit buffer verified" }
        }
    }
    func recalledPresetMatches(_ actual: UltraPreset, stored: UltraPreset) -> Bool {
        // Program recall is different from a SysEx upload: firmware upgrades old
        // records, clamps obsolete values and initializes missing preset globals.
        // Validate the checksummed readback's identity and routing, then display
        // its actual parameters. Do not require equality with the older stored bytes.
        guard actual.name == stored.name, actual.cells == stored.cells else { return false }
        let storedEffects = Set(stored.effectParameters.keys)
        let actualEffects = Set(actual.effectParameters.keys)
        return storedEffects.isSubset(of:actualEffects) && actualEffects.subtracting(storedEffects).isSubset(of:[139,140,141])
    }
    func activateDeviceSlot(_ slot: Int) {
        guard canActivateLibrary, (0..<384).contains(slot) else { return }
        selectedLibrarySlot = slot
        librarySwitching = true
        let token = UUID(); librarySwitchToken = token
        let active = { self.connected && self.librarySwitchToken == token }
        let failSwitch: (Error) -> Void = { error in
            guard active() else { return }
            self.librarySwitching = false; self.fail(error)
        }
        status = "Loading Ultra slot \(slot) • saving recovery snapshot…"
        // Always read the actual buffer, even if the UI currently shows an offline preview.
        fetchPreset { [weak self] result in
            guard let self, active() else { return }
            do {
                let original = try result.get()
                self.snapshots.insert(SavedPreset(preset:original,title:"Before library switch · " + original.name,source:"Recovery"),at:0)
                try self.saveArchive(self.snapshots,name:"snapshots")
                let messages = try UltraProtocol.program(slot,channel:self.channel)
                self.request(try UltraProtocol.storedPreset(slot,header:self.header),timeout:4,match:{ (try? UltraPreset.storedReply($0,requestedSlot:slot)) != nil }) { result in
                    guard active() else { return }
                    do {
                        let expected = try UltraPreset.storedReply(result.get(),requestedSlot:slot)
                        self.devicePresets[slot] = SavedPreset(preset:expected,title:expected.name.isEmpty ? "Empty preset" : nil,source:"Ultra slot \(slot) · bank \(["A","B","C"][slot/128])")
                        try self.sendLibraryProgram(messages[0])
                        DispatchQueue.main.asyncAfter(deadline:.now()+0.06) {
                            guard active() else { return }
                            do { try self.sendLibraryProgram(messages[1]) } catch { failSwitch(error); return }
                            DispatchQueue.main.asyncAfter(deadline:.now()+0.3) {
                                guard active() else { return }
                                self.fetchPreset { result in
                                    guard active() else { return }
                                    do {
                                        let actual = try result.get()
                                        self.inspectedLibrary = nil; self.apply(actual)
                                        self.liveUndo = []; self.liveRedo = []; self.modelUndo = nil; self.undoValues = []
                                        guard self.recalledPresetMatches(actual,stored:expected) else { throw MIDIError.message("Preset recall readback differs. Check the MIDI channel and program-change mapping. Your previous sound is in Snapshots.") }
                                        self.presetNumber = slot; self.dirty = false; self.librarySwitching = false
                                        self.status = "Loaded Ultra slot \(slot) · \(actual.name.isEmpty ? "Empty preset" : actual.name) • \(actual.payload == expected.payload ? "readback verified" : "device-converted preset • name/routing checked")"
                                    } catch { failSwitch(error) }
                                }
                            }
                        }
                    } catch { failSwitch(error) }
                }
            } catch { failSwitch(error) }
        }
    }
}
