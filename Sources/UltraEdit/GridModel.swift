import Foundation
import UltraCore

extension EditorModel {
    var canEditGrid: Bool { (canOperate || canEditDraft) && !gridWorking && !readingDevice }
    func moveBlock(from source: Int, to destination: Int, detach: Bool = false) {
        editGrid(.move(source:source,destination:destination,detach:detach),select:destination)
    }
    func editGrid(_ edit: GridEdit, select: Int? = nil) {
        guard canEditGrid, let displayed = currentPreset else { return }
        do {
            let proposed = try displayed.editingGrid(edit)
            guard proposed.payload != displayed.payload else { return }
            if draftMode { try commitDraft(proposed); if let select { selectedCell = select }; return }
        } catch { status = error.localizedDescription; return }
        gridWorking = true; status = "Updating routing…"
        let undo = gridUndo
        fetchPreset { [weak self] result in
            guard let self else { return }
            do {
                let original = try result.get()
                guard original.cells == displayed.cells else {
                    self.apply(original); throw MIDIError.message("Routing changed on the Ultra. The grid has been refreshed; try your move again.")
                }
                let next = try original.editingGrid(edit)
                self.restoreVerified(next,original:original) { [weak self] success in
                    guard let self else { return }; self.gridWorking = false
                    if success {
                        self.gridUndo = Array((undo + [original]).suffix(50)); self.gridRedo = []
                        if let select { self.selectedCell = select; let effect = self.cells[select].effect; if self.catalog?.effect(effect) != nil { self.selectedEffect = effect } }
                        self.status = "Routing updated • settings preserved • readback verified"
                    }
                }
            } catch { self.gridWorking = false; self.fail(error) }
        }
    }
    func undoGrid() { travelGrid(redo:false) }
    func redoGrid() { travelGrid(redo:true) }
    private func travelGrid(redo: Bool) {
        guard canEditGrid, let expected = currentPreset, let target = (redo ? gridRedo : gridUndo).last else { return }
        let undo = gridUndo, redos = gridRedo
        gridWorking = true
        fetchPreset { [weak self] result in
            guard let self else { return }
            do {
                let current = try result.get()
                guard current.payload == expected.payload else {
                    self.apply(current); throw MIDIError.message("The sound changed since the routing edit. History was cleared to protect the newer settings.")
                }
                self.restoreVerified(target,original:current) { [weak self] success in
                    guard let self else { return }; self.gridWorking = false
                    if success {
                        self.gridUndo = redo ? undo + [current] : Array(undo.dropLast())
                        self.gridRedo = redo ? Array(redos.dropLast()) : redos + [current]
                        self.status = redo ? "Routing redone • readback verified" : "Routing undone • readback verified"
                    }
                }
            } catch { self.gridWorking = false; self.fail(error) }
        }
    }
}
