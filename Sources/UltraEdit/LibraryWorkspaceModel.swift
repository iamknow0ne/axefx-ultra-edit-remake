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
        var presetCount = 0, cabCount = 0, duplicates = 0, failures: [String] = []
        errorMessage = nil
        for url in urls {
            do {
                guard url.isFileURL, url.pathExtension.lowercased() == "syx" else { throw MIDIError.message("Choose a Standard/Ultra .syx preset, bank or cabinet impulse.") }
                guard (try url.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? 0) <= 32*1024*1024 else { throw MIDIError.message("SysEx file exceeds 32 MB.") }
                let parsed = try UltraImport.read(Data(contentsOf:url))
                var incoming = library, cabs = importedCabinets, next = organization
                var fingerprints = Set(library.compactMap { $0.preset?.fingerprint }), added = 0, addedCabs = 0, skipped = 0
                for preset in parsed.presets {
                    guard fingerprints.insert(preset.fingerprint).inserted else { skipped += 1; continue }
                    let entry = SavedPreset(preset:preset,source:url.lastPathComponent); incoming.append(entry); added += 1
                    if let folder { next.membership[entry.id.uuidString] = folder }
                }
                for cab in parsed.cabinets {
                    let entry = try SavedCabinet(cabinet:cab,title:url.deletingPathExtension().lastPathComponent)
                    guard !cabs.contains(where:{ $0.message == entry.message }) else { skipped += 1; continue }
                    cabs.append(entry); addedCabs += 1
                }
                if addedCabs > 0 {
                    guard cabinetArchiveWritable else { throw MIDIError.message("The saved cabinet archive is protected after a read failure.") }
                    try WorkspaceFile.save(cabs,to:archiveURL("imported-cabinets")); importedCabinets = cabs; cabCount += addedCabs
                }
                if added > 0 { try saveArchive(incoming,name:"library"); library = incoming; presetCount += added }
                duplicates += skipped
                next.recentFiles.removeAll { $0 == url.path }; next.recentFiles.insert(url.path,at:0); next.recentFiles = Array(next.recentFiles.prefix(12))
                if let folder, !next.folders.contains(folder) { next.folders.append(folder) }
                organization = next; saveOrganization()
            } catch { failures.append("\(url.lastPathComponent): \(error.localizedDescription)") }
        }
        if presetCount > 0 || cabCount > 0 || duplicates > 0 { librarySource = 1; librarySearch = ""; favoritesOnly = false; libraryFolder = folder ?? "All"; libraryImportRevision += 1 }
        if cabCount > 0 && presetCount == 0 && failures.isEmpty { workbenchTab = 2; showWorkbench = true }
        status = "Imported \(presetCount) tone(s), \(cabCount) cabinet(s) • \(duplicates) duplicates • \(failures.count) skipped • hardware unchanged"
        if !failures.isEmpty { errorMessage = status + "\n\n" + failures.prefix(12).joined(separator:"\n") + (failures.count > 12 ? "\n…and \(failures.count-12) more files." : "") }
    }
    func importFolder() {
        let panel = NSOpenPanel(); panel.canChooseFiles = false; panel.canChooseDirectories = true
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let files = try FileManager.default.contentsOfDirectory(at:url,includingPropertiesForKeys:[.isRegularFileKey],options:[.skipsHiddenFiles]).filter { $0.pathExtension.lowercased() == "syx" }.sorted { $0.path < $1.path }
            guard !files.isEmpty, files.count <= 4096 else { throw MIDIError.message("Choose a folder containing 1–4096 .syx files (top level only).") }
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
                    for preset in incoming { if let slot = preset.storedSlot { self.cacheDevicePreset(preset,slot:slot) } }
                    self.deviceReadCount = presets.count; next(index+1)
                } catch { self.readingDevice = false; self.fail(error) }
            }
        }
        next(0)
    }
}
