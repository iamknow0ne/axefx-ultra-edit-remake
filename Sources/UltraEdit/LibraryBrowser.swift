import SwiftUI
import UltraCore

struct LibraryBrowser: View {
    @ObservedObject var model: EditorModel
    @State private var source = 0
    @State private var bank = -1
    @State private var folderName = ""
    private var slots: [Int] { model.visibleDeviceSlots(bank:bank) }
    var body: some View {
        VStack(spacing:8) {
            Picker("Library source",selection:$source) { Text("Ultra").tag(0); Text("On this Mac").tag(1) }.pickerStyle(.segmented).padding(.horizontal,12)
            TextField(source == 0 ? "Search name or slot (e.g. 130)" : "Search names or effects",text:$model.librarySearch).textFieldStyle(.roundedBorder).padding(.horizontal,12)
            navigation
            if source == 0 { deviceList } else { localList }
        }
    }
    private var navigation: some View {
        VStack(spacing:4) {
            HStack {
                Button { navigate(-1) } label: { Label("Previous",systemImage:"chevron.left") }
                    .disabled(!model.canActivateLibrary || !hasNeighbor(-1)).accessibilityLabel("Previous preset")
                Spacer(minLength:4)
                Button { navigate(1) } label: { Label("Next",systemImage:"chevron.right") }
                    .disabled(!model.canActivateLibrary || !hasNeighbor(1)).accessibilityLabel("Next preset")
            }.controlSize(.small)
            Text(model.librarySwitching ? "Loading on Ultra…" : "Double-click to load on Ultra")
                .font(.system(size:10)).foregroundStyle(StudioTheme.muted)
        }.padding(.horizontal,12)
    }
    private func navigate(_ direction: Int) {
        if source == 0 { model.navigateDeviceLibrary(direction,bank:bank) }
        else { model.navigateMacLibrary(direction) }
    }
    private func hasNeighbor(_ direction: Int) -> Bool {
        if source == 0 { return model.adjacentLibraryItem(slots,selected:model.selectedLibrarySlot,direction:direction) != nil }
        return model.adjacentLibraryItem(model.visibleLibrary.map(\.id),selected:model.selectedMacPreset,direction:direction) != nil
    }
    // Exclusive gestures prevent the first click's preview/read from swallowing a double-click.
    private func presetTitle(_ title: String, preview: @escaping () -> Void, load: @escaping () -> Void) -> some View {
        Text(title.isEmpty ? "Unnamed preset" : title).font(.system(size:12,weight:.semibold)).multilineTextAlignment(.leading)
            .frame(maxWidth:.infinity,alignment:.leading).contentShape(Rectangle())
            .gesture(TapGesture(count:2).exclusively(before:TapGesture()).onEnded { value in
                switch value { case .first: load(); case .second: preview() }
            })
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { preview() }
            .accessibilityAction(named:Text("Load on Ultra")) { load() }
    }
    private var deviceList: some View {
        VStack(spacing:8) {
            Picker("Bank",selection:$bank) {
                Text("All · 0–383").tag(-1); Text("A · 0–127").tag(0); Text("B · 128–255").tag(1); Text("C · 256–383").tag(2)
            }.padding(.horizontal,12)
            HStack {
                if model.readingDevice { Button("Stop",action:model.stopDeviceRead); Text("\(model.deviceReadCount) read").monospacedDigit() }
                else { Button("Read \(slots.count == 384 ? "all 384" : String(slots.count))") { model.readDeviceSlots(slots) }.disabled(!model.canActivateLibrary); Text("\(model.devicePresets.count)/384 read").monospacedDigit() }
                Spacer()
            }.font(.caption).padding(.horizontal,12)
            if !model.connected { Text("Connect to read stored presets. Reading keeps your current sound unchanged.").font(.caption).foregroundStyle(StudioTheme.muted).padding(.horizontal,12) }
            ScrollViewReader { proxy in
            List(slots,id:\.self) { slot in
                let entry = model.devicePresets[slot]
                VStack(alignment:.leading,spacing:6) {
                    HStack(alignment:.firstTextBaseline,spacing:8) {
                        Text(String(format:"%03d",slot)).font(.system(size:12,design:.monospaced)).foregroundStyle(StudioTheme.accent)
                        presetTitle(entry?.title ?? "Read preset", preview:{ model.previewDeviceSlot(slot) },load:{ model.activateDeviceSlot(slot) })
                            .disabled(model.librarySwitching || model.busy > 0 || model.readingDevice || model.draftMode || (!model.connected && entry == nil))
                            .accessibilityLabel("Slot \(slot), \(entry?.title ?? "not read")")
                    }
                    if let entry {
                        HStack(spacing:8) {
                            Button("Preview") { model.previewDeviceSlot(slot) }
                            Button("Load") { model.activateDeviceSlot(slot) }.disabled(!model.canActivateLibrary)
                            Button { model.copyDeviceSlot(slot) } label: { Image(systemName:"square.and.arrow.down") }.help("Copy to Mac library").accessibilityLabel("Copy slot \(slot) to Mac library")
                        }.controlSize(.small).disabled(model.librarySwitching || model.busy > 0 || model.readingDevice || model.draftMode)
                    }
                }.padding(.vertical,4).id(slot)
                    .listRowBackground(model.selectedLibrarySlot == slot ? StudioTheme.accent.opacity(0.12) : Color.clear)
            }.scrollContentBackground(.hidden)
                .onChange(of:model.selectedLibrarySlot) { slot in if let slot { proxy.scrollTo(slot,anchor:.center) } }
            }
            Text("Ultra slots use 0–383 numbering").font(.system(size:10)).foregroundStyle(StudioTheme.muted).padding(.bottom,4)
        }
    }
    private var localList: some View {
        VStack(spacing:8) {
            Picker("Folder",selection:$model.libraryFolder) { Text("All presets").tag("All"); ForEach(model.organization.folders,id:\.self) { Text($0).tag($0) } }.padding(.horizontal,12)
            HStack { TextField("New folder",text:$folderName).textFieldStyle(.roundedBorder); Button("Add") { model.createLibraryFolder(folderName); folderName = "" } }.padding(.horizontal,12)
            HStack { Toggle("Favorites",isOn:$model.favoritesOnly).toggleStyle(.checkbox); Spacer(); Text("\(model.visibleLibrary.count) presets") }.font(.caption).padding(.horizontal,12)
            if model.library.isEmpty { Text("Open .syx presets or copy sounds from the Ultra. This library is saved on your Mac.").font(.caption).foregroundStyle(StudioTheme.muted).padding(12); Spacer() }
            else {
                ScrollViewReader { proxy in
                List(model.visibleLibrary) { entry in
                    VStack(alignment:.leading,spacing:7) {
                        HStack {
                            presetTitle(entry.title,preview:{ model.previewMacPreset(entry) },load:{ model.activateMacPreset(entry) })
                                .disabled(model.librarySwitching || model.busy > 0 || model.draftMode)
                            Spacer()
                            Button { model.toggleFavorite(entry) } label: { Image(systemName:entry.favorite ? "star.fill" : "star") }.buttonStyle(.plain).accessibilityLabel("Favorite \(entry.title)")
                        }
                        Text(entry.source).font(.system(size:10)).foregroundStyle(StudioTheme.muted).lineLimit(1)
                        HStack { Button("Load") { model.activateMacPreset(entry) }.disabled(!model.canActivateLibrary); Button("Export") { model.exportLibrary(entry) } }.controlSize(.small)
                    }.padding(.vertical,6).id(entry.id)
                        .listRowBackground(model.selectedMacPreset == entry.id ? StudioTheme.accent.opacity(0.12) : Color.clear)
                        .contextMenu {
                        Menu("Move to folder") { Button("Unfiled") { model.assignFolder(entry,nil) }; ForEach(model.organization.folders,id:\.self) { folder in Button(folder) { model.assignFolder(entry,folder) } } }
                    }
                }.scrollContentBackground(.hidden)
                    .onChange(of:model.selectedMacPreset) { id in if let id { proxy.scrollTo(id,anchor:.center) } }
                }
            }
        }
    }
}
