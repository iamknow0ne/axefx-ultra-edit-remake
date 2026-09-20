import AppKit
import UltraCore

extension EditorModel {
    func navigateGrid(row: Int, column: Int, move: Bool) {
        let source = selectedCell ?? 0, r = source%4+row, c = source/4+column
        guard (0..<4).contains(r), (0..<12).contains(c), cells.count == 48 else { return }
        let destination = c*4+r
        if move { moveBlock(from:source,to:destination) }
        else {
            selectedCell = destination
            if catalog?.effect(cells[destination].effect) != nil { selectEffect(cells[destination].effect,cell:destination) }
        }
    }
    func removeSelectedBlock() {
        guard canEditGrid, let position = selectedCell, let preset = currentPreset, preset.cells[position].effect != 0 else { return }
        if draftMode {
            do { try commitDraft(preset.editingGrid(.remove(position))) } catch { fail(error) }; return
        }
        fetchPreset { [weak self] result in
            guard let self else { return }
            do {
                let before = try result.get()
                guard before.cells == preset.cells else { self.apply(before); throw MIDIError.message("Routing changed on the Ultra. Review the grid before removing a block.") }
                self.snapshots.insert(SavedPreset(preset:before,title:"Before removing block",source:"Recovery"),at:0)
                try self.saveArchive(self.snapshots,name:"snapshots")
                self.statusCommand(try UltraProtocol.place(effect:0,position:position,header:self.header),function:5) {
                    self.fetchPreset { result in
                        do {
                            let after = try result.get()
                            guard after.cells[position].effect == 0 else { throw MIDIError.message("Block removal readback failed") }
                            self.apply(after); self.rememberLive(before:before,after:after); self.dirty = true; self.status = "Block removed • readback verified • Undo available"
                        } catch { self.fail(error) }
                    }
                }
            } catch { self.fail(error) }
        }
    }
    func copyEffectToClipboard() {
        let effect = selectedEffect
        withFreshPreset { [weak self] preset in
            guard let self, let catalog = self.catalog else { return }
            do {
                let setting = try EffectSetting(preset:preset,effect:effect,title:catalog.name(effect),catalog:catalog)
                let data = try JSONEncoder().encode(setting)
                NSPasteboard.general.clearContents(); NSPasteboard.general.setData(data,forType:.init("tech.hostin.ultra-edit.effect"))
                self.status = "Copied \(catalog.name(effect)) settings"
            } catch { self.fail(error) }
        }
    }
    func pasteEffectFromClipboard() {
        guard let data = NSPasteboard.general.data(forType:.init("tech.hostin.ultra-edit.effect")), data.count < 65536 else { return }
        do { applyEffectSetting(try JSONDecoder().decode(EffectSetting.self,from:data)) } catch { fail(error) }
    }
}
