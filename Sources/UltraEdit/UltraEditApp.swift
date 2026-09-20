import SwiftUI
import AppKit

@main
struct UltraEditApp: App {
    @StateObject private var model = EditorModel()
    var body: some Scene {
        WindowGroup("Ultra Edit") {
            EditorView(model: model)
                .onOpenURL { model.importFiles([$0]) }
                .frame(minWidth: 1120, minHeight: 840)
                .tint(StudioTheme.accent)
                .onAppear { NSApplication.shared.setActivationPolicy(.regular); NSApplication.shared.activate(ignoringOtherApps: true) }
        }
        .defaultSize(width: 1440, height: 960)
        .commands {
            CommandGroup(replacing: .newItem) { Button("Open SysEx…",action:model.openLibrary).keyboardShortcut("o")
                Button("Import folder…",action:model.importFolder)
                Menu("Recent files") { ForEach(model.organization.recentFiles,id:\.self) { path in Button(URL(fileURLWithPath:path).lastPathComponent) { model.importFiles([URL(fileURLWithPath:path)]) } } }
                Button("Bank workspace") { model.workbenchTab = 4; model.showWorkbench = true } }
            CommandGroup(after: .saveItem) { Button("Back Up Current Preset…",action:model.backup).keyboardShortcut("s").disabled(!model.canOperate) }
            CommandGroup(replacing: .undoRedo) { Button("Undo Change",action:model.undoLast).keyboardShortcut("z").disabled(!model.hasUndo); Button("Redo Change",action:model.redoChange).keyboardShortcut("z",modifiers:[.command,.shift]).disabled(!model.hasRedo) }
        }
    }
}
