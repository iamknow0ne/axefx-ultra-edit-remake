import SwiftUI
import UltraCore

struct LibraryBrowser: View {
    @ObservedObject var model: EditorModel
    @State private var source = 0
    @State private var bank = -1
    private var slots: [Int] {
        let query = model.librarySearch.trimmingCharacters(in:.whitespacesAndNewlines)
        if let number = Int(query), (0..<384).contains(number) { return [number] }
        return (0..<384).filter { slot in
            (bank == -1 || slot/128 == bank) && (query.isEmpty || model.devicePresets[slot]?.title.localizedCaseInsensitiveContains(query) == true)
        }
    }
    var body: some View {
        VStack(spacing:8) {
            Picker("Library source",selection:$source) { Text("Ultra").tag(0); Text("On this Mac").tag(1) }.pickerStyle(.segmented).padding(.horizontal,12)
            TextField(source == 0 ? "Search name or slot (e.g. 130)" : "Search names or effects",text:$model.librarySearch).textFieldStyle(.roundedBorder).padding(.horizontal,12)
            if source == 0 { deviceList } else { localList }
        }
    }
    private var deviceList: some View {
        VStack(spacing:8) {
            Picker("Bank",selection:$bank) {
                Text("All · 0–383").tag(-1); Text("A · 0–127").tag(0); Text("B · 128–255").tag(1); Text("C · 256–383").tag(2)
            }.padding(.horizontal,12)
            HStack {
                if model.readingDevice { Button("Stop",action:model.stopDeviceRead); Text("\(model.deviceReadCount) read").monospacedDigit() }
                else { Button("Read \(slots.count == 384 ? "all 384" : String(slots.count))") { model.readDeviceSlots(slots) }.disabled(!model.connected || model.busy > 0 || model.draftMode || model.gridWorking); Text("\(model.devicePresets.count)/384 read").monospacedDigit() }
                Spacer()
            }.font(.caption).padding(.horizontal,12)
            if !model.connected { Text("Connect to read stored presets. Reading keeps your current sound unchanged.").font(.caption).foregroundStyle(StudioTheme.muted).padding(.horizontal,12) }
            List(slots,id:\.self) { slot in
                let entry = model.devicePresets[slot]
                VStack(alignment:.leading,spacing:6) {
                    HStack(alignment:.firstTextBaseline,spacing:8) {
                        Text(String(format:"%03d",slot)).font(.system(size:12,design:.monospaced)).foregroundStyle(StudioTheme.accent)
                        Button(entry?.title ?? "Read preset") { model.previewDeviceSlot(slot) }.buttonStyle(.plain).font(.system(size:12,weight:.semibold)).multilineTextAlignment(.leading)
                            .disabled(!model.connected || model.busy > 0 || model.readingDevice || model.draftMode)
                            .accessibilityLabel("Slot \(slot), \(entry?.title ?? "not read")")
                    }
                    if let entry {
                        HStack(spacing:8) {
                            Button("Preview") { model.previewDeviceSlot(slot) }
                            Button("Load") { model.audition(entry) }
                            Button { model.copyDeviceSlot(slot) } label: { Image(systemName:"square.and.arrow.down") }.help("Copy to Mac library").accessibilityLabel("Copy slot \(slot) to Mac library")
                        }.controlSize(.small).disabled(model.busy > 0 || model.readingDevice || model.draftMode)
                    }
                }.padding(.vertical,4)
            }.scrollContentBackground(.hidden)
            Text("Ultra slots use 0–383 numbering").font(.system(size:10)).foregroundStyle(StudioTheme.muted).padding(.bottom,4)
        }
    }
    private var localList: some View {
        VStack(spacing:8) {
            HStack { Toggle("Favorites",isOn:$model.favoritesOnly).toggleStyle(.checkbox); Spacer(); Text("\(model.visibleLibrary.count) presets") }.font(.caption).padding(.horizontal,12)
            if model.library.isEmpty { Text("Open .syx presets or copy sounds from the Ultra. This library is saved on your Mac.").font(.caption).foregroundStyle(StudioTheme.muted).padding(12); Spacer() }
            else {
                List(model.visibleLibrary) { entry in
                    VStack(alignment:.leading,spacing:7) {
                        HStack {
                            Button(entry.title) { model.inspect(entry) }.buttonStyle(.plain).font(.system(size:13,weight:.semibold))
                            Spacer()
                            Button { model.toggleFavorite(entry) } label: { Image(systemName:entry.favorite ? "star.fill" : "star") }.buttonStyle(.plain).accessibilityLabel("Favorite \(entry.title)")
                        }
                        Text(entry.source).font(.system(size:10)).foregroundStyle(StudioTheme.muted).lineLimit(1)
                        HStack { Button("Load") { model.audition(entry) }.disabled(!model.connected || model.busy > 0 || model.draftMode); Button("Export") { model.exportLibrary(entry) } }.controlSize(.small)
                    }.padding(.vertical,6)
                }.scrollContentBackground(.hidden)
            }
        }
    }
}
