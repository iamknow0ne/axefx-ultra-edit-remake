import SwiftUI
import UltraCore

struct WorkbenchView: View {
    @ObservedObject var model: EditorModel
    @StateObject private var lab = CabinetLabModel()
    init(model: EditorModel, lab: CabinetLabModel = CabinetLabModel()) {
        self.model = model
        _lab = StateObject(wrappedValue: lab)
    }
    var body: some View {
        VStack(spacing:0) {
            HStack {
                VStack(alignment:.leading,spacing:4) { Text("ULTRA WORKBENCH").font(.system(size:13,weight:.bold)).tracking(2); Text("Build, organize and document your sounds").font(.caption).foregroundStyle(StudioTheme.muted) }
                Spacer()
                Text(model.draftMode ? "OFFLINE DRAFT" : model.connected ? "ULTRA CONNECTED" : "OFFLINE").font(.caption.monospaced()).foregroundStyle(StudioTheme.accent)
            }.padding(20)
            Picker("Tool",selection:$model.workbenchTab) { Text("Effect settings").tag(0); Text("Setlist").tag(1); Text("Cabinet lab").tag(2); Text("Rig sheet").tag(3); Text("Banks").tag(4); Text("Modifiers").tag(5) }.pickerStyle(.segmented).padding(.horizontal,20).padding(.bottom,16).disabled(lab.working)
            Divider()
            Group {
                if model.workbenchTab == 0 { effects }
                else if model.workbenchTab == 1 { setlist }
                else if model.workbenchTab == 2 { ScrollView { CabinetLabView(model:model,lab:lab) }.onAppear { if lab.source == nil, let entry = model.importedCabinets.last { lab.loadImportedCabinet(entry) } } }
                else if model.workbenchTab == 5 { ModifierOverviewView(model:model) }
                else if model.workbenchTab == 4 { BankWorkspaceView(model:model) }
                else { rigSheet }
            }.padding(20).frame(maxWidth:.infinity,maxHeight:.infinity,alignment:.topLeading)
            Divider()
            HStack {
                if let error = model.workspaceError ?? model.errorMessage { Text(error).font(.caption).foregroundStyle(.orange).lineLimit(3) }
                Spacer()
                if lab.working { Button("Cancel NAM extraction",action:lab.cancel) }
                Button("Done") { model.showWorkbench = false }.keyboardShortcut(.cancelAction).disabled(lab.working)
            }.padding(16)
        }.frame(width:900,height:760).background(StudioTheme.panel).foregroundStyle(StudioTheme.text).preferredColorScheme(.dark).interactiveDismissDisabled(lab.working)
    }
    var effects: some View {
        VStack(alignment:.leading,spacing:16) {
            HStack(spacing:20) {
                DeviceArtwork(type:model.activeEffect?.id ?? "Amp").frame(width:140,height:92)
                VStack(alignment:.leading,spacing:6) { Text(model.catalog?.name(model.selectedEffect) ?? "Select an effect").font(.title2); Text("Save a whole effect's parameter settings and paste them into a compatible block. Destination routing and modifiers remain in place.").foregroundStyle(StudioTheme.muted).fixedSize(horizontal:false,vertical:true) }
            }
            HStack { TextField("Setting name",text:$model.effectSettingTitle).textFieldStyle(.roundedBorder); Button("Save selected effect",action:model.saveEffectSetting).disabled(model.currentPreset == nil || model.busy > 0 || !model.selectedControlsWritable || model.isPresetGlobal) }
            if model.effectSettings.isEmpty { Text("Saved effects will appear here. Select a block in the editor first.").foregroundStyle(StudioTheme.muted).padding(.vertical,24) }
            List(model.effectSettings) { setting in
                HStack {
                    DeviceArtwork(type:setting.family).frame(width:60,height:44)
                    VStack(alignment:.leading,spacing:4) { Text(setting.title).font(.headline); Text("\(setting.family) · \(setting.parameters.count) values · from \(setting.source)").font(.caption).foregroundStyle(StudioTheme.muted) }
                    Spacer()
                    Button("Paste to selected block") { model.applyEffectSetting(setting) }.disabled(model.busy > 0 || !(model.canEditDraft || model.canOperate) || model.activeEffect?.id != setting.family)
                    Button { model.removeEffectSetting(setting.id) } label: { Image(systemName:"trash") }.accessibilityLabel("Delete setting \(setting.title)")
                }.padding(.vertical,6)
            }.scrollContentBackground(.hidden)
            Text("Only matching effect families and record lengths can be pasted. A live paste captures a recovery snapshot and verifies the entire preset afterward.").font(.caption).foregroundStyle(StudioTheme.muted)
        }
    }
    var setlist: some View {
        HStack(alignment:.top,spacing:20) {
            VStack(alignment:.leading,spacing:12) {
                HStack { TextField("Setlist name",text:$model.setlist.title).font(.title2).textFieldStyle(.roundedBorder).onSubmit { model.persistTools() }; Button("Save name",action:model.persistTools) }
                HStack { Button("Add current sound",action:model.addSong).disabled(model.currentPreset == nil || model.busy > 0); Spacer(); Button("Import…",action:model.importSetlist); Button("Export…",action:model.exportSetlist) }
                if model.setlist.items.isEmpty { Text("Each song keeps its own preset copy, so the setlist travels with your sounds.").foregroundStyle(StudioTheme.muted).padding(.vertical,20) }
                List(Array(model.setlist.items.enumerated()),id:\.element.id) { index,item in
                    Button { model.selectSong(item) } label: {
                        HStack { Text(String(format:"%02d",index+1)).font(.system(.title3,design:.monospaced)).foregroundStyle(StudioTheme.accent).frame(width:36); VStack(alignment:.leading,spacing:4) { Text(item.title).font(.headline); Text(item.notes.isEmpty ? "No notes" : item.notes).font(.caption).foregroundStyle(StudioTheme.muted).lineLimit(1) }; Spacer(); if model.selectedSong == item.id { Image(systemName:"chevron.right") } }.padding(.vertical,8).contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }.scrollContentBackground(.hidden)
            }.frame(maxWidth:.infinity)
            Divider()
            VStack(alignment:.leading,spacing:14) {
                Text("SONG NOTES").font(.caption.bold()).tracking(1)
                if let song = model.setlist.items.first(where:{$0.id == model.selectedSong}) {
                    Text(song.title).font(.title2)
                    TextEditor(text:$model.songNotes).font(.body).frame(height:200).border(StudioTheme.raised)
                    Button("Save notes",action:model.saveSongNotes)
                    HStack { Button("Move up") { model.moveSong(-1) }; Button("Move down") { model.moveSong(1) } }
                    Button("Load sound into Ultra",action:model.loadSong).disabled(!model.connected || model.busy > 0 || model.draftMode)
                    Text("Replaces the edit buffer with a verified copy. Your previous sound is saved as a recovery snapshot. Loading can briefly interrupt audio.").font(.caption).foregroundStyle(StudioTheme.muted)
                    Spacer()
                    Button("Remove from setlist",action:model.removeSong)
                } else { Text("Choose a song to add performance notes or change its order.").foregroundStyle(StudioTheme.muted) }
            }.frame(width:270)
        }
    }
    var rigSheet: some View {
        VStack(alignment:.leading,spacing:20) {
            HStack(spacing:20) { Image(systemName:"doc.text").font(.system(size:48)).foregroundStyle(StudioTheme.accent); VStack(alignment:.leading,spacing:8) { Text(model.presetName).font(.title); Text("A portable record of your rig").foregroundStyle(StudioTheme.muted) } }
            Text("Export a readable Markdown sheet with the signal path, effect settings, exact raw values, and a fingerprint identifying this preset. Useful for session notes, sharing settings, or rebuilding a sound.").fixedSize(horizontal:false,vertical:true)
            Button("Export rig sheet…",action:model.exportRigSheet).disabled(model.currentPreset == nil || model.busy > 0)
            Text("Live export reads a fresh preset first. Displayed units use the recovered catalog and may be approximate. Keep a .syx backup for exact restoration, including modifiers and internal data.").font(.caption).foregroundStyle(StudioTheme.muted)
            Spacer()
        }
    }
}
