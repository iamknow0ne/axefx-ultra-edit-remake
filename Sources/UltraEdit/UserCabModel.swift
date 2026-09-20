import AppKit
import UniformTypeIdentifiers
import UltraCore

extension CabinetLabModel {
    func exportUserCab(slot: Int) {
        do {
            guard let prepared else { throw MIDIError.message("Prepare an impulse first.") }
            let cab = try UserCabIR(samples:prepared.samples,sampleRate:Int(prepared.sampleRate))
            let data = Data(try cab.message(slot:slot))
            let panel = NSSavePanel(); panel.nameFieldStringValue = "Ultra-User-Cab-\(slot).syx"
            guard panel.runModal() == .OK, let url = panel.url else { return }
            try data.write(to:url,options:.atomic)
            message = "Exported Gen-1 User Cab \(slot) • 1024 samples, 48 kHz, Q1.31. Hardware gain/audition validation pending."
        } catch { message = error.localizedDescription }
    }
}

extension EditorModel {
    func uploadOriginalUserCab(slot: Int) {
        guard canOperate else { return }
        let panel = NSOpenPanel(); panel.allowedContentTypes = [UTType(filenameExtension:"syx") ?? .data]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            guard (try url.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? 0) == 8204 else { throw MIDIError.message("Choose a single Gen-1 user cabinet .syx file.") }
            uploadUserCab(try UserCabIR(message:Array(Data(contentsOf:url))),slot:slot)
        } catch { fail(error) }
    }
    func selectUserCab(slot: Int) {
        guard canOperate, (1...10).contains(slot), let catalog,
              let parameter = catalog.effect(108)?.parameters.first(where:{ $0.key == "CABINET_TYPEL" }),
              let index = parameter.choices.firstIndex(of:"USER \(slot)") else { return }
        fetchPreset { [weak self] result in
            guard let self else { return }
            do {
                let before = try result.get()
                guard before.cells.contains(where:{ $0.effect == 108 }) else { throw MIDIError.message("Add Cabinet 1 to your preset first.") }
                let after = try before.settingParameter(effect:108,parameter:parameter.id,raw:parameter.rawMinimum+index,catalog:catalog)
                self.restoreVerified(after,original:before) { success in
                    if success { self.selectedEffect = 108; self.status = "Cabinet 1 left selects USER \(slot) • Undo restores the previous choice • listen at a low level" }
                }
            } catch { self.fail(error) }
        }
    }
    func uploadUserCab(_ cab: UserCabIR, slot: Int) {
        guard canOperate else { return }
        let alert = NSAlert(); alert.messageText = "Replace User Cab \(slot)?"
        alert.informativeText = "This permanently replaces the cabinet impulse in User Cab \(slot), which is separate from preset storage. The Ultra has no validated cabinet readback/backup path in this app. Proceed only if this slot is expendable or you have its original .syx. Transfer acceptance can be checked; audio and stored coefficients cannot be verified automatically."
        alert.addButton(withTitle:"Replace User Cab \(slot)"); alert.addButton(withTitle:"Cancel")
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        do {
            let bytes = try cab.message(slot:slot,header:header)
            // Retain the exact transmitted file for later re-upload/recovery.
            let url = archiveURL("library").deletingLastPathComponent().appendingPathComponent("Cabinet Transfers")
            try FileManager.default.createDirectory(at:url,withIntermediateDirectories:true)
            try Data(bytes).write(to:url.appendingPathComponent("user-\(slot)-\(UUID().uuidString).syx"),options:.atomic)
            statusCommand(bytes,function:10) { [weak self] in self?.status = "User Cab \(slot) transfer accepted • select USER \(slot) in Cabinet 1 to audition • no coefficient readback available" }
        } catch { fail(error) }
    }
}
