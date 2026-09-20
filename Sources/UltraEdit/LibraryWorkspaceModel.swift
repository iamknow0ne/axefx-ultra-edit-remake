import AppKit
import UltraCore
import UniformTypeIdentifiers

struct LibraryOrganization: Codable {
    var recentFiles: [String] = []
    var folders: [String] = []
    var membership: [String:String] = [:]
}

extension EditorModel {
    func loadOrganization() {
        do {
            if FileManager.default.fileExists(atPath:archiveURL("organization").path) { organization = try WorkspaceFile.load(LibraryOrganization.self,from:archiveURL("organization")) }
        } catch { toolsWritable = false; workspaceError = error.localizedDescription }
    }
    func saveOrganization() {
        do { guard toolsWritable else { throw MIDIError.message("Workspace is protected after a read failure.") }; try WorkspaceFile.save(organization,to:archiveURL("organization")) } catch { fail(error) }
    }
    func importFiles(_ urls: [URL], folder: String? = nil) {
        let folder = folder == "All" ? "All (folder)" : folder
        do {
            var incoming = library, next = organization, fingerprints = Set(library.compactMap { $0.preset?.fingerprint }), count = 0
            for url in urls {
                guard url.isFileURL, url.pathExtension.lowercased() == "syx" else { throw MIDIError.message("Open an Axe-Fx Ultra .syx preset or bank.") }
                let size = try url.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? 0
                guard size <= 32*1024*1024 else { throw MIDIError.message("SysEx file exceeds 32 MB.") }
                for preset in try UltraPreset.readFile(Data(contentsOf:url)) where fingerprints.insert(preset.fingerprint).inserted {
                    let entry = SavedPreset(preset:preset,source:url.lastPathComponent); incoming.append(entry); count += 1
                    if let folder { next.membership[entry.id.uuidString] = folder }
                }
                next.recentFiles.removeAll { $0 == url.path }; next.recentFiles.insert(url.path,at:0)
            }
            next.recentFiles = Array(next.recentFiles.prefix(12))
            if let folder, !next.folders.contains(folder) { next.folders.append(folder) }
            try saveArchive(incoming,name:"library"); library = incoming; organization = next; saveOrganization()
            status = "Imported \(count) preset(s) • duplicate sounds skipped • hardware unchanged"
        } catch { fail(error) }
    }
    func importFolder() {
        let panel = NSOpenPanel(); panel.canChooseFiles = false; panel.canChooseDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let files = try FileManager.default.contentsOfDirectory(at:url,includingPropertiesForKeys:[.isRegularFileKey],options:[.skipsHiddenFiles]).filter { $0.pathExtension.lowercased() == "syx" }.sorted { $0.path < $1.path }
            guard !files.isEmpty, files.count <= 512 else { throw MIDIError.message("Choose a folder containing 1–512 .syx files (top level only).") }
            importFiles(files,folder:url.lastPathComponent)
        } catch { fail(error) }
    }
    func assignFolder(_ entry: SavedPreset, _ folder: String?) { organization.membership[entry.id.uuidString] = folder; saveOrganization() }
    func createLibraryFolder(_ name: String) {
        let name = name.trimmingCharacters(in:.whitespacesAndNewlines)
        guard !name.isEmpty, !organization.folders.contains(name) else { return }
        guard name != "All" else { fail(MIDIError.message("Choose a folder name other than All, which is the unfiltered library.")); return }
        organization.folders.append(name); saveOrganization()
    }
    func importBank() {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [UTType(filenameExtension:"syx") ?? .data]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            guard (try url.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? 0) <= 32*1024*1024 else { throw MIDIError.message("Bank file exceeds 32 MB.") }
            let next = try BankWorkspace(presets:UltraPreset.readFile(Data(contentsOf:url)))
            changeBank(next); status = "Bank opened locally • \(next.slots.count) numbered presets"
        } catch { fail(error) }
    }
    func changeBank(_ next: BankWorkspace) { errorMessage = nil; status = "Bank workspace changed locally • hardware unchanged"; bankUndo.append(bankWorkspace); if bankUndo.count > 30 { bankUndo.removeFirst() }; bankRedo = []; bankWorkspace = next }
    func travelBank(redo: Bool) {
        errorMessage = nil; status = "Bank history applied locally • hardware unchanged"
        if redo, let next = bankRedo.popLast() { bankUndo.append(bankWorkspace); bankWorkspace = next }
        else if !redo, let old = bankUndo.popLast() { bankRedo.append(bankWorkspace); bankWorkspace = old }
    }
    func editBank(from: Int, to: Int, mode: Int) {
        do { var next = bankWorkspace; try next.transfer(from:from,to:to,copy:mode == 1,swap:mode == 2); changeBank(next) } catch { fail(error) }
    }
    func renameBank(slot: Int, name: String) {
        do { var next = bankWorkspace; try next.rename(slot,name:name); changeBank(next) } catch { fail(error) }
    }
    func exportBank(_ banks: [Int]) {
        do { saveFile(try bankWorkspace.export(banks:banks),name:banks.count == 3 ? "Ultra-All-Banks.syx" : "Ultra-Bank-\(["A","B","C"][banks[0]]).syx") } catch { fail(error) }
    }
    func backupBanks(_ banks: [Int]) {
        guard canOperate, !banks.isEmpty, banks.allSatisfy({ (0...2).contains($0) }) else { return }
        let token = UUID(); deviceReadToken = token; readingDevice = true; deviceReadCount = 0
        var presets: [UltraPreset] = []
        func next(_ index: Int) {
            guard self.connected, self.deviceReadToken == token else { return }
            guard index < banks.count else {
                self.readingDevice = false
                do {
                    let next = try BankWorkspace(presets:presets)
                    self.changeBank(next); self.exportBank(banks)
                    self.status = "Complete bank backup read • \(presets.count) presets"
                } catch { self.fail(error) }
                return
            }
            let bank = banks[index]
            self.status = "Reading bank \(["A","B","C"][bank]) • about 90 seconds over DIN MIDI"
            self.request(self.header+[3,UInt8(bank+2),0,0,0xF7],timeout:130,match:{ $0.count == 262156 && $0[5] == 4 && $0[6] == UInt8(bank+2) }) { result in
                guard self.deviceReadToken == token else { return }
                do {
                    let incoming = try UltraPreset.readFile(Data(result.get())); presets += incoming
                    for preset in incoming { if let slot = preset.storedSlot { self.devicePresets[slot] = SavedPreset(preset:preset,source:"Ultra slot \(slot)") } }
                    self.deviceReadCount = presets.count; next(index+1)
                } catch { self.readingDevice = false; self.fail(error) }
            }
        }
        next(0)
    }
}
