import AppKit
import SwiftUI
import UltraCore

/// Render the production SwiftUI views with invented data, without MIDI or user archives.
@main enum Screenshots {
    @MainActor static func main() throws {
        let app = NSApplication.shared
        app.setActivationPolicy(.prohibited)
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let output = root.appendingPathComponent("docs/images")
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
        let temporary = FileManager.default.temporaryDirectory.appendingPathComponent("UltraEditScreenshots-"+UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: temporary) }
        let model = EditorModel(storageRoot: temporary, offline: true)
        let preset = try UltraPreset(message: Array(Data(contentsOf: root.appendingPathComponent("Tests/Fixtures/synthetic-preset.syx"))))
        model.apply(preset)
        model.inspectedLibrary = UUID()
        model.selectedCell = 5
        model.selectedPage = "Basic"
        model.status = "Offline demonstration · synthetic data · no MIDI connection"
        try render(EditorView(model:model), size:NSSize(width:1440,height:960), to:output.appendingPathComponent("editor.png"))
        model.library = try ["Demo studio rig", "Clean rhythm", "Ambient lead"].map { SavedPreset(preset:try preset.renamed($0),title:$0,source:"Documentation examples",favorite:$0 == "Clean rhythm") }
        model.workbenchTab = 1
        model.setlist.title = "Studio session"
        model.setlist.items = model.library.compactMap { $0.preset }.enumerated().map { SetlistItem(preset:$0.element,notes:["Intro · neck pickup · volume rolled back", "Verse · standard tuning", "Solo · leave space for the delay tails"][$0.offset]) }
        model.selectedSong = model.setlist.items[0].id
        model.songNotes = model.setlist.items[0].notes
        try render(WorkbenchView(model:model),size:NSSize(width:900,height:760),to:output.appendingPathComponent("setlist.png"))
        let lab = CabinetLabModel()
        lab.source = try ImpulseResponse.readWAV(Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/cab-a.wav")))
        lab.second = try ImpulseResponse.readWAV(Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/cab-b.wav")))
        lab.sourceName = "Synthetic impulse A.wav"
        lab.secondName = "Synthetic impulse B.wav"
        lab.rebuild()
        lab.loadAudition(root.appendingPathComponent("Tests/Fixtures/audition.wav"))
        model.workbenchTab = 2
        try render(WorkbenchView(model:model,lab:lab),size:NSSize(width:900,height:760),to:output.appendingPathComponent("cabinet-lab.png"))
        // The real library shows all 384 addresses even with no connected device.
        model.librarySearch = "130"
        try render(EditorView(model:model,initialBrowser:1),size:NSSize(width:1440,height:960),to:output.appendingPathComponent("library.png"))
        model.bankWorkspace = try BankWorkspace(presets:["A","B","C"].flatMap { try UltraPreset.readFile(Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/Synthetic_Bank\($0).syx"))) })
        model.workbenchTab = 4
        try render(WorkbenchView(model:model),size:NSSize(width:1000,height:820),to:output.appendingPathComponent("bank-workspace.png"))
        try render(PerformanceView(model:model),size:NSSize(width:460,height:560),to:output.appendingPathComponent("performance.png"))
        print("Rendered six production views with synthetic offline data.")
    }
    @MainActor static func render<V: View>(_ view: V, size: NSSize, to url: URL) throws {
        let host = NSHostingView(rootView:view)
        host.frame = NSRect(origin:.zero,size:size)
        let window = NSWindow(contentRect:host.frame,styleMask:[.borderless],backing:.buffered,defer:false)
        window.appearance = NSAppearance(named:.darkAqua)
        window.contentView = host
        host.layoutSubtreeIfNeeded()
        RunLoop.main.run(until:Date().addingTimeInterval(0.6))
        host.layoutSubtreeIfNeeded()
        guard let bitmap = host.bitmapImageRepForCachingDisplay(in:host.bounds) else { throw MIDIError.message("Cannot render view") }
        host.cacheDisplay(in:host.bounds,to:bitmap)
        guard let data = bitmap.representation(using:.png,properties:[:]) else { throw MIDIError.message("Cannot encode PNG") }
        try data.write(to:url)
        window.orderOut(nil)
    }
}
