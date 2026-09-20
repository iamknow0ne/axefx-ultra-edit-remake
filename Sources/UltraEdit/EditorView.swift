import SwiftUI
import UltraCore

struct EditorView: View {
    @ObservedObject var model: EditorModel
    @State private var browser = 0
    @State private var showMIDI = false
    @State private var showPerformance = false
    init(model: EditorModel, initialBrowser: Int = 0) {
        self.model = model
        _browser = State(initialValue: initialBrowser)
    }
    var body: some View {
        VStack(spacing:0) {
            connectionBar
            Divider()
            presetBar
            draftBar
            GridView(model:model).equatable().padding(.horizontal,20).padding(.bottom,16)
            Divider()
            HSplitView {
                sidebar.frame(minWidth:220,idealWidth:252,maxWidth:300)
                inspector.frame(minWidth:650)
            }
            if model.showLog {
                Divider()
                HStack { Text("MIDI activity").font(.headline); Spacer(); Button("Export…",action:model.exportLog); Button("Close") { model.showLog = false } }.padding(.horizontal,12).padding(.top,8)
                MIDIActivityView(activity:model.activity)
            }
            Divider()
            HStack(spacing:8) {
                Image(systemName:model.connected ? "checkmark.circle.fill" : "circle").foregroundStyle(model.connected ? .green : StudioTheme.muted)
                Text(model.status).lineLimit(1).help(model.status)
                Spacer()
                if model.busy > 0 { ProgressView().controlSize(.small); Text("\(model.busy) pending").monospacedDigit() }
                Button("MIDI log") { model.showLog.toggle() }.buttonStyle(.borderless)
                Text("AXEFX ULTRA EDIT REMAKE  /  0.5.3").foregroundStyle(StudioTheme.muted)
            }.font(.system(size:11)).padding(.horizontal,16).frame(height:32)
        }
        .foregroundStyle(StudioTheme.text).background(StudioTheme.background)
        .preferredColorScheme(.dark)
        .onDrop(of:["public.file-url"],isTargeted:nil) { providers in
            for provider in providers { _ = provider.loadObject(ofClass:URL.self) { url,_ in if let url { DispatchQueue.main.async { model.importFiles([url]) } } } }
            return !providers.isEmpty
        }
        .alert("AxeFX Ultra Edit Remake",isPresented:Binding(get:{ model.errorMessage != nil },set:{ if !$0 { model.errorMessage = nil } })) { Button("OK") { model.errorMessage = nil } } message: { Text(model.errorMessage ?? "") }
        .sheet(isPresented:$model.showWorkbench) { WorkbenchView(model:model) }
        .sheet(isPresented:Binding(get:{ model.modifierTarget != nil },set:{ if !$0 { model.modifierTarget = nil } })) { ModifierView(model:model) }
    }
    private var connectionBar: some View {
        HStack(spacing:16) {
            HStack(spacing:10) {
                Image(systemName:"waveform.path").font(.system(size:22)).foregroundStyle(StudioTheme.accent)
                VStack(alignment:.leading,spacing:2) {
                    Text("AXEFX ULTRA EDIT").font(.system(size:12,weight:.bold)).tracking(1)
                    Text("REMAKE").font(.system(size:9,weight:.medium)).tracking(2).foregroundStyle(StudioTheme.muted)
                }
            }.frame(width:200,alignment:.leading)
            Circle().fill(model.connected ? Color.green : StudioTheme.muted).frame(width:6,height:6)
            Text(model.connected ? "AXE-FX ULTRA  ·  FW \(model.firmware)" : "AXE-FX ULTRA").font(.system(size:11,weight:.medium)).tracking(0.5)
            Spacer()
            Button("Performance") { showPerformance.toggle() }.popover(isPresented:$showPerformance) { PerformanceView(model:model) }
            Button("Workbench") { model.showWorkbench = true }
            Text(model.inputs.first(where:{$0.id == model.inputID})?.name ?? "No MIDI interface").font(.caption).foregroundStyle(StudioTheme.muted)
            Button { showMIDI.toggle() } label: { Label("MIDI setup",systemImage:"slider.horizontal.3") }.popover(isPresented:$showMIDI) { midiSetup }
            Button { if model.connected || model.connecting { model.disconnect() } else { model.connect() } } label: { Text(model.connected ? "Disconnect" : model.connecting ? "Cancel" : "Connect").frame(width:76) }.keyboardShortcut("k",modifiers:.command).disabled(model.draftMode)
        }.padding(.horizontal,20).frame(height:54).background(StudioTheme.panel)
    }
    private var midiSetup: some View {
        VStack(alignment:.leading,spacing:16) {
            Text("MIDI connection").font(.title3.bold())
            Picker("Input",selection:$model.inputID) { Text("Select input").tag(UInt32(0)); ForEach(model.inputs) { Text($0.name).tag($0.id) } }
            Picker("Output",selection:$model.outputID) { Text("Select output").tag(UInt32(0)); ForEach(model.outputs) { Text($0.name).tag($0.id) } }
            Picker("Channel",selection:$model.channel) { ForEach(1...16,id:\.self) { Text("\($0)").tag($0) } }
            Toggle("Firmware before 10.02",isOn:$model.legacy)
            if model.legacy { Stepper("SysEx ID \(model.legacyID)",value:$model.legacyID,in:0...127) }
            Text("Interface OUT → Ultra IN\nUltra OUT → interface IN").font(.caption).foregroundStyle(.secondary)
            Button("Refresh ports",action:model.refreshPorts)
        }.padding(20).frame(width:340).disabled(model.connected || model.connecting)
    }
    private var presetBar: some View {
        HStack(spacing:12) {
            VStack(alignment:.leading,spacing:4) {
                HStack(spacing:10) {
                    Text(model.presetName).font(.system(size:24,weight:.semibold)).lineLimit(1).fixedSize(horizontal:true,vertical:false)
                    if model.dirty { Text("EDITED").font(.system(size:9,weight:.bold)).tracking(1).fixedSize().foregroundStyle(StudioTheme.accent) }
                }
                Text(model.draftMode ? "OFFLINE DRAFT · AUTOSAVED" : model.inspectedLibrary != nil ? "FILE PREVIEW · OFFLINE" : model.connected ? "LIVE EDIT BUFFER" : "NOT CONNECTED").font(.system(size:10,weight:.medium)).tracking(1.2).foregroundStyle(StudioTheme.muted)
            }.frame(minWidth:160,alignment:.leading)
            Spacer()
            Button { model.refreshPreset() } label: { Label("Read Ultra",systemImage:"arrow.down.circle") }.disabled(!model.connected || model.busy > 0 || model.draftMode)
            Button { browser = 2; model.captureSnapshot() } label: { Label("Snapshot",systemImage:"camera") }.disabled(!model.canOperate && model.inspectedLibrary == nil)
            Button { model.backup() } label: { Image(systemName:"square.and.arrow.down") }.help("Export current preset backup").accessibilityLabel("Back up current preset").disabled(!model.canOperate)
            Button { model.undoLast() } label: { Image(systemName:"arrow.uturn.backward") }.help("Undo").accessibilityLabel("Undo").disabled(!model.hasUndo)
            Divider().frame(height:28)
            Text("Slot").font(.caption).foregroundStyle(StudioTheme.muted)
            TextField("Slot",value:$model.presetNumber,format:.number).frame(width:42).textFieldStyle(.roundedBorder).accessibilityLabel("Preset slot 0 to 383")
            Stepper("",value:$model.presetNumber,in:0...383).labelsHidden()
            Button("Load",action:model.recall).disabled(!model.canOperate)
            Button("Store…",action:model.store).disabled(!model.canOperate || !(0...383).contains(model.presetNumber))
        }.padding(.horizontal,20).padding(.vertical,18)
    }
    private var draftBar: some View {
        HStack(spacing:12) {
            if model.draftMode {
                Label("Offline draft",systemImage:"pencil.and.outline").foregroundStyle(StudioTheme.accent)
                Text("Changes stay on this Mac").font(.caption).foregroundStyle(StudioTheme.muted)
                Spacer()
                Button("Undo",action:model.undoDraft).disabled(model.draftUndo.isEmpty)
                Button("Redo",action:model.redoDraft).disabled(model.draftRedo.isEmpty)
                Button("Export draft…",action:model.saveDraftCopy)
                Button("Finish draft",action:model.finishDraft)
            } else {
                Button("Create offline draft",action:model.beginDraft).disabled(model.currentPreset == nil || model.busy > 0)
                if model.recoveredDraft != nil { Button("Resume saved draft",action:model.resumeDraft).disabled(model.busy > 0) }
                Spacer()
            }
        }.font(.system(size:11)).padding(.horizontal,20).padding(.bottom,12)
    }
    private var sidebar: some View {
        VStack(spacing:0) {
            Picker("Browse",selection:$browser) { Text("Effects").tag(0); Text("Library").tag(1); Text("Snapshots").tag(2) }.pickerStyle(.segmented).padding(12)
            if browser == 0 { effectsList }
            else if browser == 1 { libraryList }
            else { snapshotsList }
            Divider()
            Button("Open .syx presets or bank…",action:model.openLibrary).padding(12)
        }.background(StudioTheme.panel)
    }
    private var effectsList: some View {
        List {
            Section("IN THIS PRESET") {
                ForEach(model.cells.filter { model.catalog?.effect($0.effect) != nil }) { cell in effectButton(cell.effect,cell:cell.id) }
                if model.cells.isEmpty { Text("Read or open a preset").foregroundStyle(StudioTheme.muted) }
            }
            Section("ALL EFFECTS") {
                ForEach(model.catalog?.effects ?? []) { effect in ForEach(effect.instances) { instance in effectButton(instance.id) } }
            }
        }.listStyle(.sidebar).scrollContentBackground(.hidden)
    }
    private func effectButton(_ id: Int,cell: Int? = nil) -> some View {
        let type = model.catalog?.effect(id)?.id ?? ""
        return Button { model.showComparison = false; model.selectEffect(id,cell:cell) } label: {
            HStack(spacing:10) {
                DeviceArtwork(type:type).frame(width:38,height:28)
                Text(model.catalog?.name(id) ?? "Effect").font(.system(size:12,weight:.medium))
                Spacer()
                if model.selectedEffect == id { Image(systemName:"chevron.right").font(.system(size:9,weight:.bold)).foregroundStyle(StudioTheme.accent) }
            }.contentShape(Rectangle())
        }.buttonStyle(.plain).listRowBackground(model.selectedEffect == id ? StudioTheme.raised : Color.clear)
    }
    private var libraryList: some View {
        LibraryBrowser(model:model)
    }
    private var snapshotsList: some View {
        VStack(spacing:8) {
            TextField("Name this snapshot",text:$model.snapshotTitle).textFieldStyle(.roundedBorder).padding(.horizontal,12)
            Button("Capture current sound",systemImage:"camera",action:model.captureSnapshot).disabled(model.busy > 0 || (!model.canOperate && model.inspectedLibrary == nil))
            if model.snapshots.isEmpty { emptyState("Keep a version",detail:"Capture a sound before experimenting. Compare exact changes and restore it later, even after restarting.") }
            else {
                List(model.snapshots) { entry in
                    VStack(alignment:.leading,spacing:7) {
                        Text(entry.title).font(.system(size:13,weight:.semibold)).lineLimit(2)
                        Text(entry.created.formatted(date:.abbreviated,time:.shortened)).font(.system(size:10)).foregroundStyle(StudioTheme.muted)
                        HStack {
                            Button("Compare") { model.compareSnapshot(entry) }.disabled(model.busy > 0)
                            Button("Restore") { model.restoreSnapshot(entry) }.disabled(!model.connected || model.busy > 0 || model.draftMode)
                            Button { model.exportLibrary(entry) } label:{ Image(systemName:"square.and.arrow.up") }.accessibilityLabel("Export snapshot \(entry.title)")
                        }.controlSize(.small)
                    }.padding(.vertical,6).listRowBackground(model.comparisonID == entry.id ? StudioTheme.raised : Color.clear)
                }.scrollContentBackground(.hidden)
            }
        }
    }
    private func emptyState(_ title: String,detail: String) -> some View { VStack(alignment:.leading,spacing:10) { Text(title).font(.headline); Text(detail).font(.callout).foregroundStyle(StudioTheme.muted); Spacer() }.padding(18) }
    private var inspector: some View {
        VStack(spacing:0) {
            HStack(spacing:20) {
                DeviceArtwork(type:model.activeEffect?.id ?? "").frame(width:180,height:100)
                VStack(alignment:.leading,spacing:6) {
                    Text(model.catalog?.name(model.selectedEffect) ?? "Choose an effect").font(.system(size:22,weight:.semibold))
                    Text(model.selectedModelName.uppercased()).font(.system(size:11,weight:.semibold,design:.monospaced)).tracking(1).foregroundStyle(StudioTheme.color(model.activeEffect?.id ?? ""))
                    Text(model.draftMode ? "Offline editing · autosaved · units approximate" : model.inspectedLibrary != nil ? "Offline preview · approximate values" : model.isPresetGlobal ? "Preset globals · applied on release · full readback" : model.canEdit ? "Edits are heard on your Ultra" : "Connect to edit your sound").font(.caption).foregroundStyle(StudioTheme.muted)
                }
                Spacer()
                VStack(alignment:.trailing,spacing:10) {
                    Button(model.selectedBypassed ? "Enable block" : "Bypass block",action:model.toggleBypass).disabled(!model.canOperate || !model.selectedControlsWritable || model.isPresetGlobal || model.bypassParameter == nil)
            Button("Read controls",action:model.readParameters).disabled(!model.canOperate || !model.selectedControlsWritable || model.isPresetGlobal)
                    if model.comparisonID != nil { Button(model.showComparison ? "Show controls" : "Compare snapshot") { if model.showComparison { model.showComparison = false } else if let entry = model.snapshots.first(where:{$0.id == model.comparisonID}) { model.compareSnapshot(entry) } }.disabled(model.busy > 0) }
                }
            }.padding(.horizontal,20).padding(.vertical,10).background(StudioTheme.panel)
            if model.showComparison { comparisonView }
            else {
                HStack(spacing:12) {
                    Picker("Page",selection:$model.selectedPage) { ForEach(model.pages,id:\.self) { Text($0).tag($0) } }.frame(maxWidth:240)
                    Toggle(isOn:$model.pinnedOnly) { Label("Pinned",systemImage:"pin") }.toggleStyle(.button).help("Show only controls you have pinned")
                    Spacer()
                    TextField("Find a control",text:$model.filter).textFieldStyle(.roundedBorder).frame(maxWidth:220)
                }.padding(14)
                ScrollView {
                    LazyVGrid(columns:[GridItem(.adaptive(minimum:260),spacing:10)],spacing:10) {
                        ForEach(model.parameters) { parameter in ParameterRow(model:model,parameter:parameter).id("\(model.selectedEffect):\(parameter.id)") }
                    }.padding(.horizontal,16).padding(.bottom,16)
                    if model.parameters.isEmpty { Text(model.pinnedOnly ? "Pin a control to keep it here." : "No controls match this page and search.").foregroundStyle(StudioTheme.muted).padding(24) }
                }
            }
            Divider()
            HStack {
                TextField("Preset name (20 characters)",text:$model.renameText).textFieldStyle(.roundedBorder).frame(maxWidth:220)
                Button("Rename",action:model.renamePreset).disabled(!model.canOperate && !model.canEditDraft)
                Spacer()
                Text("\(model.parameters.count) controls").font(.caption).foregroundStyle(StudioTheme.muted)
            }.padding(12)
        }
    }
    private var comparisonView: some View {
        VStack(alignment:.leading,spacing:12) {
            HStack {
                VStack(alignment:.leading,spacing:5) { Text("Compared with \(model.comparisonTitle)").font(.headline); Text("\(model.comparison.count) \(model.comparison.count == 1 ? "difference" : "differences") · raw values are exact").font(.caption).foregroundStyle(StudioTheme.muted) }
                Spacer()
                if let entry = model.snapshots.first(where:{$0.id == model.comparisonID}) { Button("Refresh comparison") { model.compareSnapshot(entry) }.disabled(model.busy > 0) }
            }.padding(.horizontal,16).padding(.top,16)
            if model.comparison.isEmpty { emptyState("No differences",detail:"The current preset data matches this snapshot.") }
            else {
                ScrollView {
                    LazyVStack(spacing:0) {
                        ForEach(model.comparison) { change in
                            HStack(spacing:12) {
                                VStack(alignment:.leading,spacing:4) { Text(change.label).font(.system(size:13,weight:.medium)); Text(change.section).font(.caption).foregroundStyle(StudioTheme.muted) }.frame(width:190,alignment:.leading)
                                Text(change.before).foregroundStyle(StudioTheme.muted).frame(maxWidth:.infinity,alignment:.leading)
                                Image(systemName:"arrow.right").foregroundStyle(StudioTheme.accent)
                                Text(change.after).frame(maxWidth:.infinity,alignment:.leading)
                            }.font(.system(size:12,design:.monospaced)).padding(14)
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

struct ParameterRow: View {
    @ObservedObject var model: EditorModel
    let parameter: ParameterDefinition
    @State private var draft: Double = 0
    @State private var dragging = false
    var key: String { "\(model.selectedEffect):\(parameter.id)" }
    var value: ParameterValue? { model.values[key] }
    var editable: Bool { (model.canAdjust(parameter) || model.canEditDraft && parameter.id != model.activeEffect?.typeParameterID) && model.selectedControlsWritable && !parameter.name.lowercased().hasPrefix("spare") && value != nil }
    @State private var numericEntry = false
    var pinned: Bool { model.pinnedControls.contains(key) }
    var color: Color { StudioTheme.color(model.activeEffect?.id ?? "") }
    var body: some View {
        VStack(alignment:.leading,spacing:10) {
            HStack(spacing:8) {
                Text(parameter.name).font(.system(size:12,weight:.semibold)).lineLimit(1).help(parameter.name)
                Spacer(minLength:0)
                if parameter.modifierID > 0 {
                    Button { model.readModifier(parameter) } label:{ Image(systemName:"slider.horizontal.3") }.help("Modifier for \(parameter.name)").accessibilityLabel("Modifier for \(parameter.name)").disabled(!model.canOperate || model.draftMode || model.isPresetGlobal).buttonStyle(.plain)
                }
                Button { model.togglePin(parameter) } label: { Image(systemName:pinned ? "pin.fill" : "pin").foregroundStyle(pinned ? StudioTheme.accent : StudioTheme.muted) }.buttonStyle(.plain).help("Pin \(parameter.name)").accessibilityLabel("Pin \(parameter.name)")
            }
            HStack(spacing:12) {
                if parameter.choices.isEmpty && parameter.switches.isEmpty {
                    DialFace(fraction:(Double(dragging ? Int(draft) : value?.raw ?? parameter.rawMinimum)-Double(parameter.rawMinimum))/Double(max(1,parameter.rawMaximum-parameter.rawMinimum)),color:color).frame(width:50,height:50)
                }
                VStack(alignment:.leading,spacing:8) {
                    Button { numericEntry = true } label: { Text(display).font(.system(size:14,weight:.medium,design:.monospaced)).lineLimit(1).minimumScaleFactor(0.8).foregroundStyle(value == nil ? StudioTheme.muted : StudioTheme.text).help("Enter a numeric value") }.accessibilityLabel("Enter \(parameter.name) value").buttonStyle(.plain).disabled(!editable)
                        .popover(isPresented:$numericEntry) { NumericParameterEntry(parameter:parameter,raw:value?.raw ?? 0) { model.set(parameter,raw:$0) } }
                    control
                }.frame(maxWidth:.infinity,alignment:.leading)
            }
        }.padding(12).frame(maxWidth:.infinity,minHeight:104,alignment:.topLeading)
        .background(StudioTheme.panel,in:RoundedRectangle(cornerRadius:6))
        .overlay(alignment:.leading) { Rectangle().fill(color.opacity(0.65)).frame(width:2).padding(.vertical,12) }
        .onAppear { draft = Double(value?.raw ?? parameter.rawMinimum) }
        .onDisappear { if dragging { model.endLiveEdit(); dragging = false } }
        .onChange(of:value?.raw) { raw in if !dragging { draft = Double(raw ?? parameter.rawMinimum) } }
    }
    var display: String {
        if dragging { return (parameter.kind == "INT" ? "" : "≈ ") + parameter.estimate(Int(draft)) }
        if let value { return value.text.isEmpty ? (parameter.kind == "INT" ? "" : "≈ ") + parameter.estimate(value.raw) : value.text }
        return model.pendingValues.contains(key) ? "Reading…" : model.failedValues.contains(key) ? "No reply" : "Unavailable"
    }
    @ViewBuilder var control: some View {
        if !parameter.switches.isEmpty {
            HStack {
                ForEach(parameter.switches,id:\.bit) { item in
                    Toggle(item.name,isOn:Binding(get:{ (value?.raw ?? 0) & (1 << item.bit) != 0 },set:{ enabled in
                        let raw = value?.raw ?? 0; model.set(parameter,raw:enabled ? raw | (1 << item.bit) : raw & ~(1 << item.bit))
                    })).toggleStyle(.checkbox).disabled(!editable)
                }
            }
        } else if parameter.kind == "INT", !parameter.choices.isEmpty {
            Picker(parameter.name,selection:Binding(get:{ value?.raw ?? -1 },set:{ model.set(parameter,raw:$0) })) {
                Text("Unavailable").tag(-1)
                if let raw = value?.raw, !parameter.choices.indices.contains(raw-parameter.rawMinimum) { Text("Device value \(raw)").tag(raw) }
                ForEach(Array(parameter.choices.enumerated()),id:\.offset) { index,label in Text(label).tag(index+parameter.rawMinimum) }
            }.labelsHidden().disabled(!editable)
        } else {
            RawParameterSlider(value:Binding(get:{ min(Double(parameter.rawMaximum),max(Double(parameter.rawMinimum),dragging ? draft : Double(value?.raw ?? parameter.rawMinimum))) },set:{
                draft = $0.rounded()
                if !model.draftMode && !model.isPresetGlobal {
                    model.updateLive(parameter,raw:Int($0.rounded()))
                    if !dragging { model.endLiveEdit(after:0.15) }
                }
            }),in:Double(parameter.rawMinimum)...Double(max(parameter.rawMinimum+1,parameter.rawMaximum)),label:parameter.name,onEditingChanged:{ editing in
                if editing { model.markGesture("BEGIN",parameter:parameter); draft = Double(value?.raw ?? parameter.rawMinimum); dragging = true }
                else { model.markGesture("END",parameter:parameter); dragging = false; if model.draftMode || model.isPresetGlobal { model.set(parameter,raw:Int(draft)) } else { model.endLiveEdit() } }
            }).tint(color).accessibilityLabel(parameter.name).disabled(!editable)
        }
    }
}

struct ModifierView: View {
    @State private var settingName = ""
    @ObservedObject var model: EditorModel
    let fields: [(Int,String)] = [(0,"Source"),(1,"Start"),(2,"Mid"),(3,"End"),(4,"Slope"),(5,"Damping"),(10,"Auto engage"),(11,"PC reset"),(12,"Off value")]
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            Text("Modifier · \(model.modifierTarget?.name ?? "")").font(.title2)
            Text("Assign a Source first (0 = none). Shape values use the device’s raw 0–254 scale; each change is read back to verify it.").font(.caption).foregroundStyle(.secondary)
            ForEach(fields,id:\.0) { id,name in
                HStack {
                    Text(name).frame(width:100,alignment:.leading)
                    if let value = model.modifierValues[id] {
                        Text(id == 0 ? (value.0 == 0 ? "Not assigned" : "Controller \(value.0)") : "Raw value").foregroundStyle(.secondary).frame(width:180,alignment:.leading)
                        Stepper("\(value.0)",onIncrement:{ change(id,value.0+1) },onDecrement:{ change(id,value.0-1) }).disabled(model.modifierApplying || model.busy > 0 || (id != 0 && (model.modifierValues[0]?.0 ?? 0) == 0))
                    } else { Text("Reading…").foregroundStyle(.secondary) }
                }
            }
            Divider()
            HStack { TextField("Modifier preset name",text:$settingName).textFieldStyle(.roundedBorder); Button("Save") { model.saveModifierSetting(settingName) }.disabled(model.busy > 0 || model.modifierValues.count != 9 || model.modifierApplying) }
            Menu("Apply modifier preset") { ForEach(model.modifierSettings) { setting in Button(setting.title) { model.applyModifierSetting(setting) } } }.disabled(!model.canOperate || model.modifierSettings.isEmpty)
            if model.modifierApplying { ProgressView("Applying and verifying fields…") }
            HStack { Spacer(); Button("Done") { model.modifierTarget = nil }.keyboardShortcut(.defaultAction).disabled(model.modifierApplying) }
        }.padding(24).frame(width:500).interactiveDismissDisabled(model.modifierApplying)
    }
    func change(_ id: Int,_ value: Int) { guard let parameter = model.modifierTarget, (0...254).contains(value) else { return }; model.modifierRequest(parameter,id:id,value:value) }
}

struct MIDIActivityView: View {
    @ObservedObject var activity: MIDIActivityModel
    var body: some View {
        ScrollView {
            Text(activity.entries.suffix(80).joined(separator:"\n"))
                .font(.system(size:10,design:.monospaced)).textSelection(.enabled)
                .frame(maxWidth:.infinity,alignment:.leading).padding(12)
        }.frame(height:120)
    }
}

/// Build routing menus only when opened. Thousands of hidden SwiftUI menu
/// descendants otherwise participate in every enabled-state/layout update.
struct GridContextMenu: NSViewRepresentable {
    let model: EditorModel
    let position: Int
    func makeNSView(context: Context) -> GridMenuView { GridMenuView() }
    func updateNSView(_ view: GridMenuView, context: Context) { view.model = model; view.position = position }
}
final class GridMenuAction: NSObject {
    let action: () -> Void
    init(_ action: @escaping () -> Void) { self.action = action }
    @objc func invoke(_ sender: NSMenuItem) { action() }
}
final class GridMenuView: NSView {
    weak var model: EditorModel?
    var position = 0
    override func hitTest(_ point: NSPoint) -> NSView? {
        guard let event = NSApp.currentEvent,
              event.type == .rightMouseDown || (event.type == .leftMouseDown && event.modifierFlags.contains(.control)) else { return nil }
        return super.hitTest(point)
    }
    override func menu(for event: NSEvent) -> NSMenu? {
        let menu = NSMenu(); menu.autoenablesItems = false
        guard let model, model.canEditGrid else {
            let item = menu.addItem(withTitle:"Wait for the Ultra to finish, then try again",action:nil,keyEquivalent:"")
            item.isEnabled = false; return menu
        }
        let position = self.position
        func add(_ title: String, to menu: NSMenu, action: @escaping () -> Void) {
            let handler = GridMenuAction(action)
            let item = NSMenuItem(title:title,action:#selector(GridMenuAction.invoke(_:)),keyEquivalent:"")
            item.target = handler; item.representedObject = handler; menu.addItem(item)
        }
        if let selected = model.selectedCell, selected != position, model.cells.indices.contains(selected), model.cells[selected].effect != 0 {
            add("Move selected block here",to:menu) { [weak model] in model?.moveBlock(from:selected,to:position) }
            add("Move here, detach incompatible cables",to:menu) { [weak model] in model?.moveBlock(from:selected,to:position,detach:true) }
            menu.addItem(.separator())
        }
        let place = NSMenu(); place.autoenablesItems = false
        let placeItem = NSMenuItem(title:"Place effect",action:nil,keyEquivalent:""); placeItem.submenu = place; menu.addItem(placeItem)
        placeItem.isEnabled = !model.draftMode
        for type in model.catalog?.effects ?? [] where !["NoiseGate","Output","Controllers"].contains(type.id) {
            let group = NSMenu(); group.autoenablesItems = false
            for instance in type.instances {
                add(instance.name,to:group) { [weak model] in model?.place(instance.id,at:position) }
            }
            let item = NSMenuItem(title:type.name,action:nil,keyEquivalent:""); item.submenu = group; place.addItem(item)
        }
        if !model.draftMode { add("Place shunt",to:menu) { [weak model] in model?.place(200,at:position) } }
        let cell = model.cells.first { $0.id == position }
        if cell?.effect != 0 {
            if !model.draftMode { add("Remove block",to:menu) { [weak model] in model?.place(0,at:position) } }
            if position/4 > 0 {
                let inputs = NSMenu(); inputs.autoenablesItems = false
                for row in 0..<4 {
                    let source = (position/4-1)*4+row
                    let effect = model.cells.first { $0.id == source }?.effect ?? 0
                    guard effect != 0 else { continue }
                    let enabled = (cell?.inputMask ?? 0) & (1 << row) != 0
                    add("\(enabled ? "Disconnect" : "Connect") row \(row+1) · \(model.catalog?.name(effect) ?? "Block")",to:inputs) { [weak model] in
                        model?.connectCells(source:source,destination:position,enabled:!enabled)
                    }
                }
                let item = NSMenuItem(title:"Inputs from previous column",action:nil,keyEquivalent:""); item.submenu = inputs; menu.addItem(item)
            }
        }
        return menu
    }
}
