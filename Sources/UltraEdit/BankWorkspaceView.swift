import SwiftUI
import UltraCore

struct BankWorkspaceView: View {
    @ObservedObject var model: EditorModel
    @State private var bank = 0
    @State private var selected = 0
    @State private var destination = 0
    @State private var name = ""
    var body: some View {
        VStack(alignment:.leading,spacing:14) {
            HStack {
                Text("BANK WORKSPACE").font(.caption.bold()).tracking(1)
                Spacer()
                Button("Undo") { model.travelBank(redo:false) }.disabled(model.bankUndo.isEmpty)
                Button("Redo") { model.travelBank(redo:true) }.disabled(model.bankRedo.isEmpty)
                Button("Open bank…",action:model.importBank)
            }
            Text("Arrange numbered slots locally. Export a complete bank as .syx; no changes here are sent to the Ultra.").foregroundStyle(StudioTheme.muted).font(.callout)
            HStack {
                Picker("Bank",selection:$bank) { Text("A · 0–127").tag(0); Text("B · 128–255").tag(1); Text("C · 256–383").tag(2) }.pickerStyle(.segmented)
                Menu("Back up Ultra…") {
                    Button("Bank A") { model.backupBanks([0]) }; Button("Bank B") { model.backupBanks([1]) }; Button("Bank C") { model.backupBanks([2]) }; Button("All 384 slots") { model.backupBanks([0,1,2]) }
                }.disabled(!model.canOperate)
                if model.readingDevice { Button("Stop",action:model.stopDeviceRead) }
            }
            HStack(alignment:.top,spacing:20) {
                List((bank*128)..<(bank*128+128),id:\.self) { slot in
                    Button { selected = slot; name = model.bankWorkspace.preset(slot)?.name ?? "" } label: {
                        HStack { Text(String(format:"%03d",slot)).font(.system(.body,design:.monospaced)).foregroundStyle(StudioTheme.accent).frame(width:40); Text(model.bankWorkspace.preset(slot)?.name ?? "Empty slot").foregroundStyle(model.bankWorkspace.preset(slot) == nil ? StudioTheme.muted : StudioTheme.text); Spacer(); if selected == slot { Image(systemName:"chevron.right") } }.padding(.vertical,4).contentShape(Rectangle())
                    }.buttonStyle(.plain)
                }.scrollContentBackground(.hidden)
                VStack(alignment:.leading,spacing:16) {
                    Text("Slot \(selected)").font(.title2)
                    TextField("Preset name",text:$name).textFieldStyle(.roundedBorder)
                    Button("Rename") { model.renameBank(slot:selected,name:name) }.disabled(model.bankWorkspace.preset(selected) == nil)
                    Divider()
                    Stepper("Destination \(destination)",value:$destination,in:0...383)
                    TextField("Destination slot",value:$destination,formatter:NumberFormatter()).textFieldStyle(.roundedBorder)
                    HStack { Button("Move") { model.editBank(from:selected,to:destination,mode:0) }; Button("Copy") { model.editBank(from:selected,to:destination,mode:1) }; Button("Swap") { model.editBank(from:selected,to:destination,mode:2) } }.disabled(model.bankWorkspace.preset(selected) == nil)
                    Text("Move shifts intervening slots. Copy replaces the destination locally. Undo restores either action.").font(.caption).foregroundStyle(StudioTheme.muted)
                    Divider()
                    Button("Use current preset here") {
                        model.withFreshPreset { preset in
                            do { var next = model.bankWorkspace; try next.put(preset,at:selected); model.changeBank(next) } catch { model.fail(error) }
                        }
                    }.disabled(model.currentPreset == nil || model.busy > 0)
                    Spacer()
                    Button("Export bank \(["A","B","C"][bank])…") { model.exportBank([bank]) }
                    Button("Export all 384 slots…") { model.exportBank([0,1,2]) }
                }.frame(width:260)
            }
            Text(model.readingDevice ? "Reading fresh stored presets: \(model.deviceReadCount) received" : "\(model.bankWorkspace.slots.count)/384 slots populated · export requires every slot in the chosen bank").font(.caption).foregroundStyle(StudioTheme.muted)
        }.onAppear { name = model.bankWorkspace.preset(selected)?.name ?? "" }
        .onChange(of:bank) { value in selected = value*128; name = model.bankWorkspace.preset(selected)?.name ?? "" }
        .onChange(of:model.bankWorkspace.preset(selected)?.name) { value in name = value ?? "" }
    }
}

struct NumericParameterEntry: View {
    let parameter: ParameterDefinition
    let raw: Int
    let apply: (Int)->Void
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var units = false
    @State private var error: String?
    var body: some View {
        VStack(alignment:.leading,spacing:12) {
            Text(parameter.name).font(.headline)
            Picker("Entry",selection:$units) { Text("Exact raw value").tag(false); if parameter.kind != "INT", parameter.maximum > parameter.minimum { Text("Estimated \(parameter.unit.isEmpty ? "units" : parameter.unit)").tag(true) } }.pickerStyle(.segmented)
            TextField("Value",text:$text).textFieldStyle(.roundedBorder).onSubmit(commit)
            Text(units ? "Units are estimated from the legacy catalog and quantized to the Ultra’s raw scale. Readback shows the device’s actual value." : "Whole numbers from \(parameter.rawMinimum) to \(parameter.rawMaximum). Current: \(raw).") .font(.caption).foregroundStyle(.secondary)
            if let error { Text(error).font(.caption).foregroundStyle(.orange) }
            HStack { Button("Cancel") { dismiss() }; Spacer(); Button("Apply",action:commit).keyboardShortcut(.defaultAction) }
        }.padding(18).frame(width:330).onAppear { text = String(raw) }.onChange(of:units) { _ in text = ""; error = nil }
    }
    private func commit() {
        do {
            guard let value = Double(text.trimmingCharacters(in:.whitespacesAndNewlines).replacingOccurrences(of:",",with:".")) else { throw MIDIError.message("Enter a number.") }
            apply(try parameter.rawValue(for:value,estimatedUnits:units)); dismiss()
        } catch { self.error = error.localizedDescription }
    }
}
