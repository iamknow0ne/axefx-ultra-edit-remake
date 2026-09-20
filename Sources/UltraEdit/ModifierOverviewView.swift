import SwiftUI

struct ModifierOverviewView: View {
    @ObservedObject var model: EditorModel
    @State private var assignedOnly = true
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            HStack { Text("MODIFIER SOURCES").font(.caption.bold()).tracking(1); Spacer(); Toggle("Assigned only",isOn:$assignedOnly); if model.modifierScanning { Button("Stop",action:model.stopModifierScan) } else { Button("Read current preset",action:model.readModifierOverview).disabled(!model.canOperate) } }
            Text("Read the controller sources attached to this preset’s effects. Select Edit to open its curve and save or apply a reusable modifier preset.").foregroundStyle(StudioTheme.muted)
            List(model.modifierAssignments.filter { !assignedOnly || $0.source != 0 }) { item in
                HStack {
                    Text(model.catalog?.name(item.effect) ?? "Effect").frame(width:140,alignment:.leading)
                    Text(item.parameter.name).frame(maxWidth:.infinity,alignment:.leading)
                    Text(item.source == 0 ? "Unassigned" : "Controller \(item.source)").foregroundStyle(StudioTheme.muted)
                    Button("Edit") { model.selectedEffect = item.effect; model.showWorkbench = false; DispatchQueue.main.asyncAfter(deadline:.now()+0.25) { model.readModifier(item.parameter) } }.disabled(!model.canOperate)
                }.padding(.vertical,6)
            }.scrollContentBackground(.hidden)
            Text("\(model.modifierAssignments.filter { $0.source != 0 }.count) assignments found · \(model.modifierSettings.count) saved modifier presets").font(.caption).foregroundStyle(StudioTheme.muted)
        }
    }
}
