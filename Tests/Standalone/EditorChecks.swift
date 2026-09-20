import Foundation
import UltraCore

@main enum EditorChecks {
    static func main() throws {
        let root = URL(fileURLWithPath:FileManager.default.currentDirectoryPath)
        let baseline = try UltraPreset(message:Array(Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/synthetic-preset.syx"))))
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("UltraEditChecks-"+UUID().uuidString)
        defer { try? FileManager.default.removeItem(at:directory) }
        let model = EditorModel(storageRoot:directory,offline:true)
        var storedReads = 0
        var corruptNextUpload = false
        var device = baseline, requests: [[UInt8]] = []
        func update(_ payload: [UInt8]) {
            device = try! UltraPreset(message:UltraProtocol.modernHeader + [4,1,0,0] + payload.flatMap { UltraProtocol.nibbles(Int($0)) } + UltraProtocol.nibbles(Int(payload.reduce(0,^))) + [0xF7])
        }
        model.attachTestTransport { bytes in
            requests.append(bytes)
            let h = UltraProtocol.modernHeader
            var reply: [UInt8]
            switch bytes[5] {
            case 3:
                if bytes[6] == 0 {
                    storedReads += 1
                    let slot = Int(bytes[7]) | Int(bytes[8]) << 4
                    reply = try baseline.forStorage(slot:slot & 255)
                    // A reply for a different address must never populate this slot.
                    model.receiveTestMessage(try baseline.forStorage(slot:(slot+1)%384))
                } else { reply = device.forEditBuffer() }
            case 2:
                let effect = UltraProtocol.byte(bytes[6],bytes[7]), id = UltraProtocol.byte(bytes[8],bytes[9])
                precondition(![139,140,141].contains(effect),"Global query is forbidden")
                if bytes[12] == 0 { precondition(id != model.catalog!.effect(effect)?.typeParameterID,"Model query is forbidden") }
                if bytes[12] == 1 {
                    var payload = device.payload, offset = 130
                    while offset+2 < payload.count {
                        let count = Int(payload[offset+1])
                        if Int(payload[offset]) == effect { payload[offset+2+id] = UInt8(UltraProtocol.byte(bytes[10],bytes[11])); break }
                        precondition(count > 0); offset += 2+count
                    }
                    update(payload)
                }
                let raw = Int(device.effectParameters[effect]![id])
                reply = h + [2]
                reply += Array(bytes[6..<10]); reply += UltraProtocol.nibbles(raw)
                reply += Array("Device \(raw)".utf8); reply += [0,0xF7]
            case 4:
                device = try UltraPreset(message:bytes)
                if corruptNextUpload { device = try device.renamed("Rejected QA"); corruptNextUpload = false }
                reply = h+[11,4,1,0xF7]
            case 9:
                var payload = device.payload; payload.replaceSubrange(2..<22,with:bytes[6..<26]); update(payload); reply = h+[11,9,1,0xF7]
            default: throw MIDIError.message("Unexpected test message")
            }
            DispatchQueue.main.asyncAfter(deadline:.now()+0.002) { model.receiveTestMessage(reply) }
        }
        func drain() {
            let until = Date().addingTimeInterval(8)
            repeat { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) } while (model.busy > 0 || model.readingDevice) && Date() < until
            precondition(model.busy == 0,"Queue stuck")
            precondition(model.errorMessage == nil,model.errorMessage ?? "")
        }
        model.refreshPreset(); drain()
        precondition(model.presetName == baseline.name && model.values["106:1"]?.text == "Device 151","Initial read must populate live controls")
        print("PASS initial refresh, live control reads and unsafe-query exclusion")
        model.snapshotTitle = "Baseline"; model.captureSnapshot(); drain()
        precondition(model.snapshots.count == 1 && model.snapshots[0].preset?.payload == baseline.payload)
        let drive = model.catalog!.effect(106)!.parameters.first { $0.id == 1 }!
        model.set(drive,raw:150); drain(); precondition(model.undoValues.count == 1)
        model.compareSnapshot(model.snapshots[0]); drain()
        precondition(model.comparison.count == 1 && model.comparison[0].id == "106:1")
        model.undoLast(); drain(); precondition(device.payload == baseline.payload && model.undoValues.isEmpty)
        print("PASS snapshot, one-control diff, parameter edit and undo")
        model.readParameters()
        precondition(model.canAdjust(drive), "Background reads must not lock the slider")
        let gestureStart = requests.count
        for index in 0..<200 { model.updateLive(drive,raw:index == 199 ? 149 : 150) }
        RunLoop.main.run(until:Date().addingTimeInterval(0.2))
        precondition(device.effectParameters[106]?[1] == 149, "Drag must reach hardware before release")
        precondition(model.liveKey == "106:1" && !model.canOperate && model.canAdjust(drive))
        let gestureRequests = Array(requests.dropFirst(gestureStart))
        let firstWrite = gestureRequests.firstIndex { $0[5] == 2 && $0[12] == 1 }!
        precondition(firstWrite <= 1, "Live edit must overtake queued background reads")
        precondition(gestureRequests.filter { $0[5] == 2 && $0[12] == 1 }.count <= 2, "Old pointer values must be coalesced")
        model.endLiveEdit(); drain()
        precondition(model.undoValues.count == 1 && model.values["106:1"]?.raw == 149)
        model.undoLast(); drain(); precondition(device.payload == baseline.payload && model.undoValues.isEmpty)
        print("PASS live updates before release, background priority, bounded backlog and one-step gesture undo")
        model.renameText = "Renamed"; model.renamePreset(); drain()
        precondition(model.presetName == "Renamed","Status completion must refresh even while activity count is still nonzero")
        model.restoreForTest(baseline); drain()
        precondition(device.payload == baseline.payload && model.presetName == baseline.name)
        precondition(model.snapshots.contains { $0.source == "Recovery" && $0.preset?.name == "Renamed" })
        let restarted = EditorModel(storageRoot:directory,offline:true)
        precondition(restarted.snapshots.count == model.snapshots.count)
        print("PASS rename refresh, verified restore, recovery capture and persisted snapshots")
        let count = requests.count
        model.selectEffect(139); drain(); precondition(requests.count == count && !model.selectedControlsWritable)
        print("PASS global controls cannot issue MIDI reads or writes")
        model.selectEffect(106); drain()
        model.beginDraft(); drain()
        let draftRequestCount = requests.count
        model.set(drive,raw:149); model.renameText = "Offline song"; model.renamePreset()
        precondition(model.currentPreset?.effectParameters[106]?[1] == 149)
        precondition(model.draftUndo.count == 2 && requests.count == draftRequestCount)
        model.undoDraft(); model.undoDraft(); precondition(model.currentPreset?.payload == baseline.payload)
        model.redoDraft(); model.redoDraft(); precondition(model.presetName == "Offline song")
        let draftRestart = EditorModel(storageRoot:directory,offline:true); draftRestart.resumeDraft()
        precondition(draftRestart.currentPreset?.payload == model.currentPreset?.payload)
        precondition(device.payload == baseline.payload)
        print("PASS offline edit, rename, undo/redo, crash recovery and zero MIDI writes")
        model.effectSettingTitle = "Saved drive"; model.saveEffectSetting()
        model.set(drive,raw:145); model.applyEffectSetting(model.effectSettings[0])
        precondition(model.currentPreset?.effectParameters[106]?[1] == 149 && requests.count == draftRequestCount)
        model.addSong(); model.songNotes = "Drop D"; model.saveSongNotes()
        let toolsRestart = EditorModel(storageRoot:directory,offline:true)
        precondition(toolsRestart.effectSettings.count == 1 && toolsRestart.setlist.items[0].notes == "Drop D")
        precondition(toolsRestart.setlist.items[0].preset?.payload == model.currentPreset?.payload)
        print("PASS effect settings and self-contained setlist persistence")
        model.finishDraft(); drain(); precondition(model.currentPreset?.payload == baseline.payload)
        model.selectedSong = model.setlist.items[0].id; model.loadSong(); drain()
        precondition(device.name == "Offline song" && device.effectParameters[106]?[1] == 149)
        model.restoreForTest(baseline); drain()
        model.applyEffectSetting(model.effectSettings[0]); drain()
        precondition(device.effectParameters[106]?[1] == 149)
        precondition(model.snapshots.last != nil)
        model.restoreForTest(baseline); drain(); precondition(device.payload == baseline.payload)
        print("PASS setlist load and live effect paste use full readback with recovery")
        let ampCell = baseline.cells.first { $0.effect == 106 }!.id
        let emptyCell = ampCell/4*4+(ampCell%4+1)%4
        model.moveBlock(from:ampCell,to:emptyCell); drain()
        precondition(device.cells[emptyCell].effect == 106 && model.gridUndo.count == 1 && !model.gridWorking)
        precondition(model.snapshots.contains { $0.source == "Recovery" && $0.preset?.payload == baseline.payload })
        let movedPayload = device.payload
        model.undoGrid(); drain(); precondition(device.payload == baseline.payload && model.gridRedo.count == 1)
        model.redoGrid(); drain(); precondition(device.payload == movedPayload && model.gridUndo.count == 1)
        model.undoLast(); drain(); precondition(device.payload == baseline.payload)
        print("PASS grid move, recovery, verified undo/redo and main Undo integration")
        // Front-panel parameter changes must survive a move based on a fresh dump.
        device = try baseline.settingParameter(effect:106,parameter:1,raw:147,catalog:model.catalog!)
        model.moveBlock(from:ampCell,to:emptyCell); drain()
        precondition(device.effectParameters[106]?[1] == 147)
        // A newer external edit must block history restoration rather than overwrite it.
        device = try device.settingParameter(effect:106,parameter:1,raw:148,catalog:model.catalog!)
        model.undoGrid()
        let rejectUntil = Date().addingTimeInterval(3)
        while model.busy > 0 && Date() < rejectUntil { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
        precondition(model.errorMessage != nil && device.effectParameters[106]?[1] == 148 && model.gridUndo.isEmpty && !model.gridWorking)
        model.errorMessage = nil; model.restoreForTest(baseline); drain()
        print("PASS grid edit keeps fresh front-panel values and rejects stale undo")
        let beforeRejectedMove = requests.count
        device = try baseline.editingGrid(.move(source:ampCell,destination:emptyCell))
        model.moveBlock(from:ampCell,to:emptyCell)
        let staleUntil = Date().addingTimeInterval(3)
        while model.busy > 0 && Date() < staleUntil { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
        precondition(model.errorMessage != nil && !model.gridWorking && requests.dropFirst(beforeRejectedMove).allSatisfy { $0[5] == 3 })
        model.errorMessage = nil; model.restoreForTest(baseline); drain()
        corruptNextUpload = true
        model.moveBlock(from:ampCell,to:emptyCell)
        let mismatchUntil = Date().addingTimeInterval(4)
        while model.busy > 0 && Date() < mismatchUntil { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
        precondition(model.errorMessage?.contains("readback differs") == true && !model.gridWorking && model.gridUndo.isEmpty && model.values.isEmpty)
        precondition(model.snapshots.first?.preset?.payload == baseline.payload)
        model.errorMessage = nil; model.restoreForTest(baseline); drain()
        print("PASS stale-grid rejection sends no write; mismatched readback retains recovery and unlocks")
        model.beginDraft(); drain(); let gridDraftRequests = requests.count
        model.moveBlock(from:ampCell,to:emptyCell)
        precondition(model.currentPreset?.cells[emptyCell].effect == 106 && requests.count == gridDraftRequests)
        model.undoDraft(); precondition(model.currentPreset?.payload == baseline.payload)
        model.finishDraft(); drain()
        print("PASS offline grid movement and undo send no MIDI")
        let storedRequestStart = requests.count
        model.readDeviceSlots([0,127,128,130,255,256,383]); drain()
        precondition(model.devicePresets.count == 7 && model.devicePresets[130]?.preset?.storedSlot == 130)
        precondition(model.devicePresets[383]?.preset?.storedSlot == 383 && !model.readingDevice)
        precondition(device.payload == baseline.payload && model.currentPreset?.payload == baseline.payload)
        precondition(requests.dropFirst(storedRequestStart).allSatisfy { $0[5] == 3 && $0[6] == 0 })
        model.copyDeviceSlot(130); precondition(model.library.last?.source.contains("130") == true)
        model.readDeviceSlots([1,2,3]); model.stopDeviceRead(); drain()
        precondition(storedReads == 8 && model.devicePresets[1] == nil && !model.readingDevice)
        print("PASS stored bank boundaries, address matching, duplicate names, cancellation and no writes")
        let beforeCancel = requests.count
        model.updateLive(drive,raw:150); model.updateLive(drive,raw:149); model.endLiveEdit(after:0.15)
        model.disconnect()
        RunLoop.main.run(until:Date().addingTimeInterval(0.2))
        precondition(requests.count == beforeCancel+1 && model.liveKey == nil && device.effectParameters[106]?[1] == 150)
        // An already submitted packet cannot be recalled; deferred target 149 must never send.
        device = baseline
        print("PASS disconnect cancels delayed live writes and stale gesture completion")
        let lab = CabinetLabModel()
        lab.source = try ImpulseResponse.readWAV(Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/cab-a.wav")))
        lab.second = try ImpulseResponse.readWAV(Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/cab-b.wav")))
        lab.rebuild(); precondition(lab.prepared?.samples.count == 1024 && lab.frequencyPoints.count == 180)
        lab.loadAudition(root.appendingPathComponent("Tests/Fixtures/audition.wav"))
        precondition(lab.previewReady && (lab.previewAudio?.peak ?? 0) > 0.001)
        let audioURL = directory.appendingPathComponent("model-audition.wav")
        try lab.previewAudio!.wavData().write(to:audioURL)
        lab.second = lab.source; lab.invert = true; lab.mix = 0.5; lab.rebuild()
        precondition(lab.prepared == nil && !lab.previewReady && lab.previewAudio == nil)
        print("PASS cabinet model, real PCM clip, convolution export and cancellation-state invalidation")
        lab.second = nil; lab.invert = false
        lab.extractNAM(root.appendingPathComponent("Tests/Fixtures/wavenet.nam"))
        let namUntil = Date().addingTimeInterval(20)
        while lab.working && Date() < namUntil { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
        precondition(!lab.working && lab.namReport != nil && lab.prepared?.samples.count == 1024,lab.message)
        print("PASS app model launches native NAM helper and prepares its actual response")
        print("16 editor integration groups passed")
    }
}
