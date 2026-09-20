import Foundation
import UltraCore

struct LiveHistoryStep {
    let before: UltraPreset
    let after: UltraPreset
}
extension EditorModel {
    func rememberLive(before: UltraPreset, after: UltraPreset) {
        guard before.payload != after.payload else { return }
        // A routing-only restore must not discard a later parameter change.
        // Routing transactions restore their own captured stack after this call.
        gridUndo = []; gridRedo = []
        if liveUndo.last?.after.payload != before.payload { liveUndo = [] }
        liveUndo.append(LiveHistoryStep(before:before,after:after)); liveUndo = Array(liveUndo.suffix(50)); liveRedo = []
    }
    func travelLive(redo: Bool) {
        guard canOperate, let step = (redo ? liveRedo : liveUndo).last else { return }
        let expected = redo ? step.before : step.after, target = redo ? step.after : step.before
        let undos = liveUndo, redos = liveRedo
        fetchPreset { [weak self] result in
            guard let self else { return }
            do {
                let actual = try result.get()
                guard actual.payload == expected.payload else {
                    self.liveUndo = []; self.liveRedo = []; self.undoValues = []; self.modelUndo = nil; self.apply(actual)
                    throw MIDIError.message("The sound changed on the Ultra. History was cleared to protect the newer settings.")
                }
                self.restoreVerified(target,original:actual,recordHistory:false) { success in
                    guard success else { return }
                    self.liveUndo = redo ? undos + [step] : Array(undos.dropLast())
                    self.liveRedo = redo ? Array(redos.dropLast()) : redos + [step]
                    self.status = redo ? "Change redone • full preset verified" : "Change undone • full preset verified"
                }
            } catch { self.fail(error) }
        }
    }
}
