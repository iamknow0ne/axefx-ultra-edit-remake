import AppKit
import Combine
import UniformTypeIdentifiers
import UltraCore

/// Diagnostics update only their own view, never the complete editor graph.
final class MIDIActivityModel: ObservableObject {
    @Published var entries: [String] = []
}
typealias LibraryEntry = SavedPreset
final class EditorModel: ObservableObject {
    @Published var catalog: Catalog?
    @Published var inputs: [MIDIEndpoint] = []
    @Published var outputs: [MIDIEndpoint] = []
    @Published var inputID: UInt32 = 0
    @Published var outputID: UInt32 = 0
    @Published var channel = 1
    @Published var legacy = false
    @Published var legacyID = 125
    @Published var connected = false
    @Published var connecting = false
    @Published var firmware = ""
    @Published var status = "Choose your MIDI ports, then connect."
    @Published var errorMessage: String?
    @Published var selectedEffect: Int = 106
    @Published var selectedCell: Int?
    @Published var selectedPage = "All"
    @Published var filter = ""
    @Published var presetName = "No preset loaded"
    @Published var renameText = ""
    @Published var presetNumber = 0
    @Published var values: [String: ParameterValue] = [:]
    @Published var pendingValues: Set<String> = []
    @Published var failedValues: Set<String> = []
    @Published var cells: [GridCell] = []
    @Published var gridWorking = false
    @Published var gridUndo: [UltraPreset] = []
    @Published var gridRedo: [UltraPreset] = []
    @Published var devicePresets: [Int: SavedPreset] = [:]
    @Published var readingDevice = false
    @Published var deviceReadCount = 0
    var deviceReadToken = UUID()
    @Published var busy = 0
    @Published private(set) var liveKey: String?
    private var liveEdit: LiveParameterEdit?
    private var liveEnd: DispatchWorkItem?
    let activity = MIDIActivityModel()
    var log: [String] { activity.entries }
    @Published var library: [LibraryEntry] = []
    @Published var inspectedLibrary: UUID?
    @Published var dirty = false
    @Published var showConnections = true
    @Published var tunerReading: TunerReading?
    @Published var tunerAt: Date?
    @Published var tempoAt: Date?
    @Published var observedBPM: Double?
    @Published var tapCC = 14
    @Published var tunerCC = 15
    @Published var performanceMappingConfirmed = false
    @Published var tunerCommandedOn = false
    var tempoMessages = 0
    @Published var showLog = false
    @Published var modifierSettings: [ModifierSetting] = []
    @Published var modifierAssignments: [ModifierAssignment] = []
    @Published var modifierScanning = false
    @Published var modifierApplying = false
    var modifierScanToken = UUID()
    @Published var modifierValues: [Int: (Int,String)] = [:]
    @Published var modifierTarget: ParameterDefinition?
    @Published var liveUndo: [LiveHistoryStep] = []
    @Published var liveRedo: [LiveHistoryStep] = []
    @Published var undoValues: [ParameterValue] = []
    @Published var modelUndo: UltraPreset?
    @Published var snapshots: [SavedPreset] = []
    @Published var snapshotTitle = ""
    @Published var comparisonID: UUID?
    @Published var showComparison = false
    @Published var librarySearch = ""
    @Published var favoritesOnly = false
    @Published var pinnedOnly = false
    @Published var pinnedControls: Set<String> = Set(UserDefaults.standard.stringArray(forKey:"pinnedControls") ?? [])
    @Published var workspaceRevision = 0
    @Published var showWorkbench = false
    @Published var workbenchTab = 0
    @Published var draftMode = false
    @Published var recoveredDraft: SavedPreset?
    @Published var draftUndo: [UltraPreset] = []
    @Published var draftRedo: [UltraPreset] = []
    @Published var effectSettings: [EffectSetting] = []
    @Published var effectSettingTitle = ""
    @Published var setlist = PerformanceSetlist()
    @Published var selectedSong: UUID?
    @Published var songNotes = ""
    @Published var workspaceError: String?
    @Published var organization = LibraryOrganization()
    @Published var libraryFolder = "All"
    @Published var bankWorkspace = BankWorkspace()
    @Published var bankUndo: [BankWorkspace] = []
    @Published var bankRedo: [BankWorkspace] = []
    var toolsWritable = true
    private let storageRoot: URL?
    private var archiveWritable = true
    private var transport: MIDITransport?
    private var queue: RequestQueue?
    var currentPreset: UltraPreset?
    private var keepAlive: Timer?
    private var consecutiveTimeouts = 0
    private var lastReply = Date.distantPast
    private let logClock: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    var header: [UInt8] { UltraProtocol.header(legacy: legacy, legacyID: UInt8(clamping: legacyID)) }
    var activeEffect: EffectDefinition? { catalog?.effect(selectedEffect) }
    var parameters: [ParameterDefinition] { (activeEffect?.parameters ?? []).filter { (selectedPage == "All" || $0.page == selectedPage) && (!pinnedOnly || pinnedControls.contains("\(selectedEffect):\($0.id)")) && (filter.isEmpty || $0.name.localizedCaseInsensitiveContains(filter) || $0.key.localizedCaseInsensitiveContains(filter)) } }
    var pages: [String] { ["All"] + (activeEffect?.parameters.map(\.page) ?? []).reduce(into: [String]()) { if !$0.contains($1) { $0.append($1) } } }
    var canEdit: Bool { !draftMode && connected && currentPreset != nil && inspectedLibrary == nil && !connecting && !gridWorking && !modifierApplying && !modifierScanning }
    var canOperate: Bool { canEdit && busy == 0 && liveKey == nil && !readingDevice && !modifierScanning && !modifierApplying }
    var selectedControlsWritable: Bool { catalog?.effect(selectedEffect) != nil }
    init(storageRoot: URL? = nil, offline: Bool = false) {
        self.storageRoot = storageRoot
        let candidates = [Bundle.main.url(forResource: "UltraCatalog", withExtension: "json"), URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Resources/UltraCatalog.json")].compactMap { $0 }
        do { guard let url = candidates.first(where: { FileManager.default.fileExists(atPath: $0.path) }) else { throw MIDIError.message("UltraCatalog.json is missing from the application.") }; catalog = try Catalog(url: url) }
        catch { errorMessage = error.localizedDescription }
        do { library = try PresetArchive.load(archiveURL("library")); snapshots = try PresetArchive.load(archiveURL("snapshots")) }
        catch { archiveWritable = false; errorMessage = error.localizedDescription }
        loadProductivity(); loadOrganization(); loadModifierSettings()
        if !offline && !CommandLine.arguments.contains("--offline") { initializeMIDI() }
        else { status = "Offline • Browse the recovered Ultra controls or open a .syx preset." }
    }
    func initializeMIDI() {
        do {
            let midi = try MIDITransport(); transport = midi
            let requests = RequestQueue(sendLong: { [weak midi] bytes in guard let midi else { throw MIDIError.message("MIDI is unavailable.") }; try midi.sendSysEx(bytes) }) { [weak midi] bytes in guard let midi else { throw MIDIError.message("MIDI is unavailable.") }; try midi.send(bytes) }
            queue = requests
            requests.onActivity = { [weak self] count in if self?.busy != count { self?.busy = count } }
            requests.onSent = { [weak self] bytes in self?.appendLog("TX",bytes) }
            midi.onMessage = { [weak self] bytes in self?.receive(bytes) }
            midi.onChange = { [weak self] in self?.refreshPorts() }
            refreshPorts()
        } catch { errorMessage = error.localizedDescription }
    }
    func refreshPorts() {
        inputs = MIDITransport.endpoints(input: true); outputs = MIDITransport.endpoints(input: false)
        if !inputs.contains(where: { $0.id == inputID }) || !outputs.contains(where: { $0.id == outputID }) {
            if connected || connecting { disconnect(); status = "MIDI interface disconnected. Reconnect it, then press Connect." }
        }
        if !inputs.contains(where: { $0.id == inputID }) { inputID = inputs.first(where: { $0.uniqueID == UserDefaults.standard.integer(forKey: "inputUID") })?.id ?? inputs.first?.id ?? 0 }
        if !outputs.contains(where: { $0.id == outputID }) { outputID = outputs.first(where: { $0.uniqueID == UserDefaults.standard.integer(forKey: "outputUID") })?.id ?? outputs.first?.id ?? 0 }
    }
    func connect() {
        guard !draftMode else { fail(MIDIError.message("Finish the offline draft before connecting.")); return }
        guard inputID != 0, outputID != 0 else { errorMessage = "Select both a MIDI input and output."; return }
        do {
            if transport == nil { initializeMIDI() }
            try transport?.connect(source: inputID, destination: outputID)
            cancelLiveEdit(); queue?.cancel(); connecting = true; connected = false; inspectedLibrary = nil; currentPreset = nil; cells = []; values = [:]; pendingValues = []; failedValues = []; undoValues = []; modelUndo = nil; dirty = false
            tempoMessages = 0; status = "Waiting for the Axe-Fx Ultra…"; errorMessage = nil
            UserDefaults.standard.set(inputs.first { $0.id == inputID }?.uniqueID, forKey: "inputUID")
            UserDefaults.standard.set(outputs.first { $0.id == outputID }?.uniqueID, forKey: "outputUID")
            request( UltraProtocol.firmware(header: header), timeout: 2.5, match: { $0.count == 9 && $0[5] == 8 }) { [weak self] result in
                guard let self else { return }; self.connecting = false
                switch result {
                case .success(let bytes):
                    self.connected = true; self.firmware = "\(bytes[6]).\(String(format:"%02d",bytes[7]))"; self.consecutiveTimeouts = 0
                    self.status = "Axe-Fx Ultra • Firmware \(self.firmware)"; self.refreshPreset()
                    self.keepAlive?.invalidate()
                    self.keepAlive = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in self?.ping() }
                case .failure(let error): self.fail(error); self.status = self.tempoMessages > 0 ? "Ultra tempo received • no reply to requests" : "MIDI port open • Ultra did not answer"; self.transport?.disconnect()
                }
            }
        } catch { connecting = false; fail(error) }
    }
    func disconnect() {
        stopModifierScan(); modifierApplying = false
        tunerReading = nil; tunerAt = nil; tempoAt = nil; observedBPM = nil; performanceMappingConfirmed = false
        stopDeviceRead(); liveUndo = []; liveRedo = []; gridWorking = false; gridUndo = []; gridRedo = []; devicePresets = [:]
        keepAlive?.invalidate(); keepAlive = nil; cancelLiveEdit(); queue?.cancel(); transport?.disconnect(); connected = false; connecting = false
        pendingValues = []; failedValues = []; values = [:]; undoValues = []; modelUndo = nil; dirty = false; currentPreset = nil; cells = []; status = "Disconnected"
    }
    private func ping() {
        guard connected, busy == 0, liveKey == nil, inspectedLibrary == nil else { return }
        request(UltraProtocol.firmware(header: header), match: { $0.count == 9 && $0[5] == 8 }) { [weak self] result in
            guard let self else { return }
            if case .failure = result { self.disconnect(); self.status = "Connection lost • press Connect to retry." }
        }
    }
    private func receive(_ bytes: [UInt8]) {
        guard UltraProtocol.validEnvelope(bytes), Array(bytes.prefix(5)) == header else { return }
        if receivePerformance(bytes) { return }
        if bytes[5] == 0x10 { tempoMessages += 1; if connecting { status = "Ultra tempo received • waiting for query reply…" }; return }
        lastReply = Date(); appendLog("RX",bytes)
        queue?.receive(bytes)
    }
    func sendController(_ cc: Int, value: Int) throws {
        guard let transport else { throw MIDIError.message("MIDI unavailable") }
        let bytes = try UltraProtocol.controller(cc,value:value,channel:channel)
        try transport.send(bytes); appendLog("TX",bytes)
    }
    func request(_ bytes: [UInt8], timeout: Double = 1.5, priority: RequestQueue.Priority = .normal, match: @escaping ([UInt8])->Bool, completion: @escaping (Result<[UInt8],Error>)->Void) {
        queue?.enqueue(.init(bytes: bytes, timeout: timeout, priority: priority, matches: match, completion: completion))
    }
    func refreshPreset() { guard !draftMode else { return }; liveUndo = []; liveRedo = []; modelUndo = nil; reloadPreset() }
    private func reloadPreset() {
        guard connected else { return }
        stopDeviceRead(); stopModifierScan()
        cancelLiveEdit(); queue?.cancel(); inspectedLibrary = nil; values = [:]; pendingValues = []; failedValues = []; undoValues = []
        request(UltraProtocol.patch(header: header), timeout: 4, match: { $0.count == 2060 && $0[5] == 4 && $0[6] == 1 }) { [weak self] result in
            guard let self else { return }
            do { let preset = try UltraPreset(message: result.get()); self.apply(preset); self.status = "Current edit buffer read • \(preset.name)"; self.readParameters() }
            catch { self.fail(error) }
        }
    }
    func apply(_ preset: UltraPreset) {
        gridUndo = []; gridRedo = []
        currentPreset = preset
        values = [:]
        workspaceRevision += 1
        for (effect, parameters) in preset.effectParameters {
            for (id, raw) in parameters.enumerated() where raw <= 254 {
                values["\(effect):\(id)"] = ParameterValue(effect:effect, parameter:id, raw:Int(raw), text:"")
            }
        }
        cells = preset.cells; presetName = preset.name; renameText = preset.name
        if let selectedCell, cells.indices.contains(selectedCell), cells[selectedCell].effect != selectedEffect, let current = cells.first(where:{ $0.effect == selectedEffect }) { self.selectedCell = current.id }
        let present = Set(cells.map(\.effect))
        if !present.contains(selectedEffect), ![139,140,141].contains(selectedEffect), let first = cells.first(where: { catalog?.effect($0.effect) != nil }) { selectedEffect = first.effect; selectedCell = first.id }
    }
    func selectEffect(_ effect: Int, cell: Int? = nil) {
        endLiveEdit(); selectedEffect = effect; selectedCell = cell; selectedPage = "All"; filter = ""
        if canEdit && busy == 0 { readParameters() }
    }
    func readParameters() {
        guard canEdit, selectedControlsWritable, !isPresetGlobal, let effect = activeEffect else { return }
        let effectID = selectedEffect
        for parameter in effect.parameters {
            // Firmware 11 reinitializes the amp when TYPE is queried, even with
            // query flag 0. All model/mode selectors come from the patch dump.
            guard parameter.id != effect.typeParameterID, !parameter.name.lowercased().hasPrefix("spare"),
                  let record = currentPreset?.effectParameters[effectID], parameter.id < record.count else { continue }
            let key = "\(effectID):\(parameter.id)"
            if pendingValues.contains(key) { continue }
            pendingValues.insert(key)
            do {
                let bytes = try UltraProtocol.parameter(effect: effectID, parameter: parameter.id, header: header)
                request(bytes, priority:.background, match: { UltraProtocol.response($0)?.key == key }) { [weak self] result in
                    guard let self else { return }; self.pendingValues.remove(key)
                    switch result {
                    case .success(let bytes): if let value = UltraProtocol.response(bytes) { if self.liveKey != key { self.values[key] = value }; self.failedValues.remove(key); self.consecutiveTimeouts = 0 }
                    case .failure: self.failedValues.insert(key); self.consecutiveTimeouts += 1
                        if self.consecutiveTimeouts >= 3 { self.cancelLiveEdit(); self.queue?.cancel(); self.pendingValues = []; self.status = "Parameter reads stopped after three missing replies. Refresh or reconnect." }
                    }
                }
            } catch { pendingValues.remove(key); fail(error) }
        }
    }
    func set(_ parameter: ParameterDefinition, raw: Int, recordUndo: Bool = true) {
        if isPresetGlobal { setPresetGlobal(parameter,raw:raw); return }
        if draftMode { editDraft(parameter,raw:raw); return }
        guard canAdjust(parameter), (parameter.rawMinimum...parameter.rawMaximum).contains(raw) else { return }
        let effect = selectedEffect, key = "\(selectedEffect):\(parameter.id)"
        guard let old = values[key], raw != old.raw else { return }
        if parameter.id == activeEffect?.typeParameterID {
            guard busy == 0, liveKey == nil else { return }
            request(UltraProtocol.patch(header:header), timeout:4, match:{ $0.count == 2060 && $0[5] == 4 && $0[6] == 1 }) { [weak self] result in
                guard let self else { return }
                do {
                    let snapshot = try UltraPreset(message:result.get())
                    let recovery = SavedPreset(preset:snapshot,title:"Before model change · " + snapshot.name,source:"Recovery")
                    self.snapshots.insert(recovery,at:0); try self.saveArchive(self.snapshots,name:"snapshots")
                    let bytes = try UltraProtocol.parameter(effect:effect,parameter:parameter.id,value:raw,header:self.header)
                    self.request(bytes,match:{ UltraProtocol.response($0)?.key == key }) { [weak self] result in
                        guard let self else { return }
                        do {
                            guard UltraProtocol.response(try result.get())?.raw == raw else { throw MIDIError.message("Model change rejected") }
                            self.fetchPreset { result in
                                do {
                                    let after = try result.get()
                                    guard after.effectParameters[effect]?[parameter.id] == UInt8(raw) else { throw MIDIError.message("Model readback differs") }
                                    self.apply(after); self.rememberLive(before:snapshot,after:after); self.modelUndo = snapshot; self.dirty = true; self.readParameters()
                                } catch { self.fail(error) }
                            }
                        } catch { self.fail(error) }
                    }
                } catch { self.fail(error) }
            }
            return
        }
        updateLive(parameter,raw:raw,recordUndo:recordUndo)
        endLiveEdit()
    }
    func canAdjust(_ parameter: ParameterDefinition) -> Bool {
        guard canEdit, selectedControlsWritable, !parameter.name.lowercased().hasPrefix("spare"),
              currentPreset?.effectParameters[selectedEffect]?.indices.contains(parameter.id) == true,
              values["\(selectedEffect):\(parameter.id)"] != nil else { return false }
        if isPresetGlobal || parameter.id == activeEffect?.typeParameterID { return canOperate }
        if let liveKey { return liveKey == "\(selectedEffect):\(parameter.id)" }
        return queue?.hasForegroundWork == false
    }
    func updateLive(_ parameter: ParameterDefinition, raw: Int, recordUndo: Bool = true) {
        guard !draftMode, !isPresetGlobal, canAdjust(parameter), parameter.id != activeEffect?.typeParameterID,
              (parameter.rawMinimum...parameter.rawMaximum).contains(raw), let queue else { return }
        liveEnd?.cancel(); liveEnd = nil
        let key = "\(selectedEffect):\(parameter.id)"
        if liveEdit == nil {
            guard let original = values[key], original.raw != raw else { return }
            let edit = LiveParameterEdit(effect:selectedEffect,parameter:parameter.id,initial:original.raw,header:header,queue:queue)
            liveEdit = edit; liveKey = key
            edit.onAcknowledged = { [weak self, weak edit] value in
                guard let self, let edit, self.liveEdit === edit else { return }
                if value.raw == edit.target { self.values[key] = value }
            }
            edit.completion = { [weak self, weak edit] result in
                guard let self, let edit, self.liveEdit === edit else { return }
                self.liveEdit = nil; self.liveKey = nil
                switch result {
                case .success(let value):
                    self.values[key] = value; self.failedValues.remove(key)
                    if recordUndo && value.raw != original.raw {
                        self.undoValues.append(original)
                        if let before = self.currentPreset, let catalog = self.catalog,
                           let after = try? before.settingParameter(effect:value.effect,parameter:value.parameter,raw:value.raw,catalog:catalog) {
                            self.currentPreset = after; self.rememberLive(before:before,after:after)
                        }
                    }
                    else if !recordUndo && !self.undoValues.isEmpty { self.undoValues.removeLast() }
                    self.dirty = true; self.status = "\(parameter.name): \(value.text) • readback verified"
                case .failure(let error):
                    self.queue?.cancel(); self.pendingValues = []
                    self.values.removeValue(forKey:key); self.failedValues.insert(key); self.fail(error)
                }
            }
        }
        values[key] = ParameterValue(effect:selectedEffect,parameter:parameter.id,raw:raw,text:"")
        status = "\(parameter.name) • live"
        liveEdit?.update(raw)
    }
    func markGesture(_ phase: String, parameter: ParameterDefinition) {
        guard !draftMode else { return }
        activity.entries.append("\(logClock.string(from:Date())) UI \(phase) \(selectedEffect):\(parameter.id)")
        if activity.entries.count > 500 { activity.entries.removeFirst(activity.entries.count-500) }
    }
    func endLiveEdit(after delay: Double = 0) {
        liveEnd?.cancel()
        if delay == 0 { liveEdit?.finish(); liveEnd = nil }
        else {
            let work = DispatchWorkItem { [weak self] in self?.liveEdit?.finish(); self?.liveEnd = nil }
            liveEnd = work; DispatchQueue.main.asyncAfter(deadline:.now()+delay,execute:work)
        }
    }
    private func cancelLiveEdit() {
        liveEnd?.cancel(); liveEnd = nil; liveEdit?.cancel(); liveEdit = nil; liveKey = nil
    }
    func undoLast() {
        if draftMode { undoDraft(); return }
        if canOperate, !liveUndo.isEmpty { travelLive(redo:false); return }
        if canOperate, !gridUndo.isEmpty, undoValues.isEmpty { undoGrid(); return }
        if canOperate, let snapshot = modelUndo, undoValues.isEmpty {
            restoreVerified(snapshot)
            return
        }
        guard canOperate, let value = undoValues.last, let parameter = catalog?.effect(value.effect)?.parameters.first(where: { $0.id == value.parameter }) else { return }
        selectedEffect = value.effect; set(parameter,raw: value.raw,recordUndo: false)
    }
    func renamePreset() {
        if draftMode { do { if let preset = currentPreset { try commitDraft(preset.renamed(renameText)) } } catch { fail(error) }; return }
        guard canOperate else { return }
        let name = renameText
        do { _ = try UltraProtocol.rename(name) } catch { fail(error); return }
        fetchPreset { [weak self] result in
            guard let self else { return }
            do {
                let original = try result.get(), renamed = try original.renamed(name)
                guard original.payload != renamed.payload else { return }
                self.restoreVerified(renamed, original:original)
            } catch { self.fail(error) }
        }
    }
    func recall() {
        guard canOperate else { return }
        if !confirm("Load preset \(presetNumber)?", "The current edit buffer will be replaced. Save a snapshot first to keep unsaved changes, including changes made on the front panel.") { return }
        do {
            let messages = try UltraProtocol.program(presetNumber, channel: channel)
            try transport?.send(messages[0]); appendLog("TX",messages[0])
            connecting = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) { [weak self] in
                guard let self, self.connected else { return }
                do { try self.transport?.send(messages[1]); self.appendLog("TX",messages[1]) } catch { self.fail(error) }
                DispatchQueue.main.asyncAfter(deadline: .now()+0.3) { [weak self] in self?.connecting = false; self?.dirty = false; self?.modelUndo = nil; self?.refreshPreset() }
            }
        } catch { fail(error) }
    }
    func statusCommand(_ bytes: [UInt8], function: UInt8, failure: ((Error)->Void)? = nil, completion: @escaping ()->Void) {
        request(bytes, timeout: 3, match: { UltraProtocol.status($0,for:function) != nil }) { [weak self] result in
            do { let reply = try result.get(); guard UltraProtocol.status(reply,for:function) == 1 else { throw MIDIError.message("The Ultra rejected this change.") }; completion() } catch { self?.fail(error); failure?(error) }
        }
    }
    func place(_ effect: Int, at position: Int) {
        guard canOperate else { return }
        if let cell = cells.first(where: { $0.id == position }), cell.effect != 0, !confirm("Replace \(catalog?.name(cell.effect) ?? "block")?", "The block at row \(position%4+1), column \(position/4+1) will be replaced in the edit buffer.") { return }
        do { statusCommand(try UltraProtocol.place(effect: effect,position: position,header: header), function: 5) { [weak self] in self?.dirty = true; self?.refreshPreset() } } catch { fail(error) }
    }
    func connectCells(source: Int, destination: Int, enabled: Bool) {
        editGrid(.link(GridLink(source:source,destination:destination),enabled:enabled))
    }
    func backup() {
        guard connected, busy == 0, liveKey == nil, inspectedLibrary == nil else { return }
        request(UltraProtocol.patch(header: header), timeout: 4, match: { $0.count == 2060 && $0[5] == 4 && $0[6] == 1 }) { [weak self] result in
            do { let preset = try UltraPreset(message: result.get()); self?.apply(preset); self?.saveFile(Data(preset.message), name: preset.name + ".syx"); self?.status = "Backup received and checksum verified." } catch { self?.fail(error) }
        }
    }
    func openLibrary() {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [UTType(filenameExtension:"syx") ?? .data]; panel.allowsMultipleSelection = true
        guard panel.runModal() == .OK else { return }
        importFiles(panel.urls)
    }
    func inspect(_ entry: LibraryEntry) {
        guard !draftMode, busy == 0, liveKey == nil, let preset = entry.preset else { return }
        inspectedLibrary = entry.id; values = [:]; apply(preset); status = "File preview • \(entry.source) • hardware unchanged"
    }
    func exportLibrary(_ entry: LibraryEntry) { guard let preset = entry.preset else { return }; saveFile(Data(preset.message),name: entry.title + ".syx") }
    func audition(_ entry: LibraryEntry) {
        guard connected, busy == 0, liveKey == nil, let preset = entry.preset else { return }
        guard confirm("Load \(entry.title) into the Ultra?", "This replaces the edit buffer. A recovery snapshot is captured first. Stored presets stay unchanged.") else { return }
        restoreVerified(preset)
    }

    func store() {
        guard canOperate else { return }
        guard confirm("Store to preset \(presetNumber)?", "This overwrites slot \(presetNumber) on the Ultra with the current edit buffer. A local backup of the destination will be saved first.") else { return }
        let slot = presetNumber
        guard (0...383).contains(slot) else { fail(MIDIError.message("Preset slot must be 0–383.")); return }
        // Back up the destination before any persistent hardware write.
        let getStored = try! UltraProtocol.storedPreset(slot,header:header)
        request(getStored, timeout: 4, match: { (try? UltraPreset.storedReply($0,requestedSlot:slot)) != nil }) { [weak self] result in
            guard let self else { return }
            do {
                let old = try UltraPreset.storedReply(result.get(),requestedSlot:slot)
                let backupDirectory = try self.backupDirectory()
                let url = backupDirectory.appendingPathComponent("slot-\(slot)-\(Int(Date().timeIntervalSince1970)).syx")
                try Data(old.message).write(to: url, options: .atomic)
                self.request(UltraProtocol.patch(header: self.header),timeout: 4,match: { $0.count == 2060 && $0[5] == 4 && $0[6] == 1 }) { [weak self] result in
                    guard let self else { return }
                    do {
                        let preset = try UltraPreset(message: result.get())
                        let message = try preset.forStorage(slot: slot,header: self.header)
                        self.statusCommand(message,function: 4) { [weak self] in
                            guard let self else { return }
                            self.request(getStored,timeout: 4,match: { (try? UltraPreset.storedReply($0,requestedSlot:slot)) != nil }) { [weak self] verification in
                                do { let stored = try UltraPreset.storedReply(verification.get(),requestedSlot:slot); guard stored.payload == preset.payload else { throw MIDIError.message("Stored preset readback differs. Original backup: \(url.path)") }; self?.dirty = false; self?.status = "Stored to \(slot) • readback verified • original backed up" } catch { self?.fail(error) }
                            }
                        }
                    } catch { self.fail(error) }
                }
            } catch { self.fail(error) }
        }
    }
    func readModifier(_ parameter: ParameterDefinition) {
        guard canOperate, selectedControlsWritable, !isPresetGlobal, currentPreset?.effectParameters[selectedEffect]?.indices.contains(parameter.id) == true, parameter.modifierID > 0 else { return }
        modifierTarget = parameter; modifierValues = [:]
        for id in [0,1,2,3,4,5,10,11,12] { modifierRequest(parameter,id: id,value: nil) }
    }
    func modifierRequest(_ parameter: ParameterDefinition, id: Int, value: Int?) {
        guard canEdit, selectedControlsWritable, !isPresetGlobal else { return }
        if value != nil { guard busy == 0, liveKey == nil, id == 0 || (modifierValues[0]?.0 ?? 0) != 0 else { return } }
        let effect = selectedEffect
        let matches: ([UInt8])->Bool = { b in b.count >= 16 && b[5] == 7 && UltraProtocol.byte(b[6],b[7]) == effect && UltraProtocol.byte(b[8],b[9]) == parameter.modifierID && UltraProtocol.byte(b[10],b[11]) == id }
        let decode: ([UInt8]) throws -> (Int,String) = { bytes in
            guard bytes[6..<14].allSatisfy({ $0 < 16 }), bytes[bytes.count-2] == 0 else { throw MIDIError.message("Malformed modifier reply") }
            return (UltraProtocol.byte(bytes[12],bytes[13]),String(bytes:bytes[14..<(bytes.count-2)],encoding:.ascii) ?? "")
        }
        do {
            request(try UltraProtocol.modifier(effect:effect,parameter:parameter.modifierID,modifier:id,value:value,header:header),match:matches) { [weak self] result in
                guard let self else { return }
                do {
                    let echoed = try decode(result.get())
                    guard value != nil else { self.modifierValues[id] = echoed; return }
                    self.request(try UltraProtocol.modifier(effect:effect,parameter:parameter.modifierID,modifier:id,header:self.header),match:matches) { [weak self] result in
                        guard let self else { return }
                        do {
                            let verified = try decode(result.get()); self.modifierValues[id] = verified
                            guard verified.0 == echoed.0 else { throw MIDIError.message("The modifier change did not persist. Assign a source before editing its shape.") }
                            self.dirty = true; self.status = "Modifier change read back and verified"
                            if id == 0 { for field in [1,2,3,4,5,10,11,12] { self.modifierRequest(parameter,id:field,value:nil) } }
                        } catch { self.fail(error) }
                    }
                } catch { self.fail(error) }
            }
        } catch { fail(error) }
    }
    var visibleLibrary: [SavedPreset] { library.filter { (!favoritesOnly || $0.favorite) && (libraryFolder == "All" || organization.membership[$0.id.uuidString] == libraryFolder) && $0.matches(librarySearch,catalog:catalog) }.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending } }
    var comparison: [PresetChange] {
        guard let catalog, let old = snapshots.first(where:{ $0.id == comparisonID })?.preset, let currentPreset else { return [] }
        return currentPreset.changes(from:old,catalog:catalog)
    }
    var comparisonTitle: String { snapshots.first { $0.id == comparisonID }?.title ?? "Choose a snapshot" }
    var selectedModelName: String {
        guard let id = activeEffect?.typeParameterID, let parameter = activeEffect?.parameters.first(where:{ $0.id == id }), let value = values["\(selectedEffect):\(id)"] else { return activeEffect?.name ?? "Effect" }
        return parameter.estimate(value.raw)
    }
    func togglePin(_ parameter: ParameterDefinition) {
        let key = "\(selectedEffect):\(parameter.id)"
        if pinnedControls.contains(key) { pinnedControls.remove(key) } else { pinnedControls.insert(key) }
        UserDefaults.standard.set(Array(pinnedControls).sorted(),forKey:"pinnedControls")
    }
    func toggleFavorite(_ entry: SavedPreset) {
        guard let index = library.firstIndex(where:{ $0.id == entry.id }) else { return }
        library[index].favorite.toggle()
        do { try saveArchive(library,name:"library") } catch { fail(error) }
    }
    func captureSnapshot() {
        guard busy == 0, liveKey == nil else { return }
        let title = snapshotTitle.trimmingCharacters(in:.whitespacesAndNewlines)
        if draftMode || inspectedLibrary != nil, let preset = currentPreset { addSnapshot(preset,title:title); return }
        guard canOperate else { return }
        fetchPreset { [weak self] result in
            guard let self else { return }
            do { let preset = try result.get(); self.apply(preset); self.addSnapshot(preset,title:title) } catch { self.fail(error) }
        }
    }
    private func addSnapshot(_ preset: UltraPreset, title: String) {
        let entry = SavedPreset(preset:preset,title:title.isEmpty ? preset.name + " · " + Date().formatted(date:.omitted,time:.shortened) : title,source:"Snapshot")
        snapshots.insert(entry,at:0)
        do { try saveArchive(snapshots,name:"snapshots"); comparisonID = entry.id; snapshotTitle = ""; status = "Snapshot saved locally • \(entry.title)" } catch { fail(error) }
    }
    func compareSnapshot(_ entry: SavedPreset) {
        guard busy == 0, liveKey == nil else { return }
        comparisonID = entry.id; showComparison = true
        guard canOperate else { return }
        fetchPreset { [weak self] result in
            do { let preset = try result.get(); self?.apply(preset) } catch { self?.fail(error) }
        }
    }
    func restoreSnapshot(_ entry: SavedPreset) {
        guard connected, busy == 0, liveKey == nil, let preset = entry.preset else { return }
        guard confirm("Restore \(entry.title)?", "Your current sound is saved as a recovery snapshot first. This changes only the edit buffer.") else { return }
        restoreVerified(preset)
    }
    func fetchPreset(_ completion: @escaping (Result<UltraPreset,Error>)->Void) {
        request(UltraProtocol.patch(header:header),timeout:4,match:{ $0.count == 2060 && $0[5] == 4 && $0[6] == 1 }) { result in completion(result.flatMap { bytes in Result { try UltraPreset(message:bytes) } }) }
    }
    func restoreVerified(_ preset: UltraPreset, original: UltraPreset? = nil, recordHistory: Bool = true, completion: ((Bool)->Void)? = nil) {
        guard !draftMode, connected, liveKey == nil, busy == 0 || original != nil else { return }
        let perform: (Result<UltraPreset,Error>)->Void = { [weak self] result in
            guard let self else { return }
            do {
                let original = try result.get()
                let recovery = SavedPreset(preset:original,title:"Before restore · " + original.name,source:"Recovery")
                self.snapshots.insert(recovery,at:0)
                try self.saveArchive(self.snapshots,name:"snapshots")
                self.statusCommand(preset.forEditBuffer(header:self.header),function:4,failure:{ _ in completion?(false) }) { [weak self] in
                    guard let self else { return }
                    self.fetchPreset { [weak self] result in
                        guard let self else { return }
                        do {
                            let verified = try result.get()
                            guard verified.payload == preset.payload else { throw MIDIError.message("Restore readback differs. The recovery snapshot retains your previous sound.") }
                            self.inspectedLibrary = nil; self.modelUndo = nil; self.undoValues = []; self.dirty = true
                            self.apply(verified); self.showComparison = false
                            if recordHistory { self.rememberLive(before:original,after:verified) }
                            self.status = "Restored \(verified.name) • all 1024 bytes verified"
                            completion?(true)
                        } catch { self.values = [:]; self.fail(error); completion?(false) }
                    }
                }
            } catch { self.fail(error); completion?(false) }
        }
        if let original { perform(.success(original)) } else { fetchPreset(perform) }
    }
    func archiveURL(_ name: String) -> URL {
        let root = storageRoot ?? FileManager.default.urls(for:.applicationSupportDirectory,in:.userDomainMask)[0].appendingPathComponent("Ultra Edit")
        return root.appendingPathComponent(name + ".json")
    }
    func saveArchive(_ entries: [SavedPreset], name: String) throws {
        guard archiveWritable else { throw MIDIError.message("The existing archive could not be read; it will not be overwritten. Resolve the archive error before saving presets.") }
        try PresetArchive.save(entries,to:archiveURL(name))
    }
    func exportLog() { saveFile(Data(log.joined(separator:"\n").utf8),name:"Ultra-Edit-MIDI-log.txt") }
    private func backupDirectory() throws -> URL {
        let dir = archiveURL("library").deletingLastPathComponent().appendingPathComponent("Backups")
        try FileManager.default.createDirectory(at: dir,withIntermediateDirectories:true); return dir
    }
    func saveFile(_ data: Data, name: String) {
        let panel = NSSavePanel(); panel.nameFieldStringValue = name.replacingOccurrences(of:"/",with:"-")
        if panel.runModal() == .OK, let url = panel.url { do { try data.write(to:url,options:.atomic) } catch { fail(error) } }
    }
    private func confirm(_ title: String,_ message: String) -> Bool { let alert = NSAlert(); alert.messageText = title; alert.informativeText = message; alert.addButton(withTitle:"Continue"); alert.addButton(withTitle:"Cancel"); return alert.runModal() == .alertFirstButtonReturn }
    private func appendLog(_ direction: String,_ bytes: [UInt8]) {
        let text = bytes.prefix(80).map { String(format:"%02X",$0) }.joined(separator:" ")
        activity.entries.append("\(logClock.string(from:Date())) \(direction) [\(bytes.count)] \(text)\(bytes.count > 80 ? " …" : "")")
        if activity.entries.count > 500 { activity.entries.removeFirst(activity.entries.count-500) }
    }
    func fail(_ error: Error) { errorMessage = error.localizedDescription; status = error.localizedDescription }
#if EDITOR_TESTS
    func attachTestTransport(_ sender: @escaping ([UInt8]) throws -> Void) {
        queue = RequestQueue(sendLong:sender,send:sender)
        queue?.onActivity = { [weak self] count in if self?.busy != count { self?.busy = count } }
        connected = true
    }
    func receiveTestMessage(_ bytes: [UInt8]) { receive(bytes) }
    func restoreForTest(_ preset: UltraPreset) { restoreVerified(preset) }
#endif

}
