import Foundation
import UltraCore

@main enum EditorChecks {
    static func main() throws {
        let root = URL(fileURLWithPath:FileManager.default.currentDirectoryPath)
        let baseline = try UltraPreset(message:Array(Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/synthetic-preset.syx"))))
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("UltraEditChecks-"+UUID().uuidString)
        defer { try? FileManager.default.removeItem(at:directory) }
        let model = EditorModel(storageRoot:directory,offline:true)
        var modifierFields: [String:Int] = [:]
        var storedReads = 0
        var corruptNextUpload = false
        var programBank = 0
        var ignoreNextProgram = false
        var holdHeartbeat = false
        var device = baseline, requests: [[UInt8]] = []
        func update(_ payload: [UInt8]) {
            device = try! UltraPreset(message:UltraProtocol.modernHeader + [4,1,0,0] + payload.flatMap { UltraProtocol.nibbles(Int($0)) } + UltraProtocol.nibbles(Int(payload.reduce(0,^))) + [0xF7])
        }
        model.attachTestTransport { bytes in
            requests.append(bytes)
            if bytes[0] & 0xF0 == 0xB0 { programBank = Int(bytes[2]); return }
            if bytes[0] & 0xF0 == 0xC0 {
                if ignoreNextProgram { ignoreNextProgram = false; return }
                device = try baseline.renamed("Slot \(programBank*128+Int(bytes[1]))"); return
            }
            let h = UltraProtocol.modernHeader
            var reply: [UInt8]
            switch bytes[5] {
            case 8:
                if holdHeartbeat { return }
                reply = h+[8,11,0,0xF7]
            case 3:
                if bytes[6] == 0 {
                    storedReads += 1
                    let slot = Int(bytes[7]) | Int(bytes[8]) << 4
                    reply = try baseline.renamed("Slot \(slot)").forStorage(slot:slot & 255)
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
            case 7:
                let key = bytes[6..<12].map(String.init).joined(separator:":")
                if bytes[14] == 1 { modifierFields[key] = UltraProtocol.byte(bytes[12],bytes[13]) }
                reply = h+[7]+Array(bytes[6..<12])+UltraProtocol.nibbles(modifierFields[key] ?? 0)+[0,247]
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
            let until = Date().addingTimeInterval(20)
            repeat { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) } while (model.busy > 0 || model.readingDevice || model.modifierScanning || model.modifierApplying || model.librarySwitching) && Date() < until
            precondition(model.busy == 0,"Queue stuck")
            precondition(model.errorMessage == nil,model.errorMessage ?? "")
        }
        model.refreshPreset(); drain()
        precondition(model.presetName == baseline.name && model.values["106:1"]?.text == "Device 151","Initial read must populate live controls")
        print("PASS initial refresh, live control reads and unsafe-query exclusion")
        holdHeartbeat = true
        let beforeHeartbeat = requests.count
        for _ in 0..<3 { model.ping() }
        precondition(requests.count == beforeHeartbeat+1, "Only one health probe may be outstanding")
        precondition(model.busy == 0 && model.canOperate && model.canActivateLibrary, "Health checks must not grey out controls")
        RunLoop.main.run(until:Date().addingTimeInterval(0.05))
        precondition(model.busy == 0 && model.canOperate)
        model.snapshotTitle = "During health check"; model.captureSnapshot()
        precondition(model.busy > 0 && !model.canOperate, "Actual user transactions must still lock controls")
        model.receiveTestMessage(UltraProtocol.modernHeader+[8,11,0,0xF7])
        holdHeartbeat = false; drain()
        precondition(model.snapshots.count == 1 && model.snapshots[0].preset?.payload == baseline.payload)
        print("PASS silent health probe, duplicate suppression and serialized foreground work")
        model.snapshotTitle = "Baseline"; model.captureSnapshot(); drain()
        precondition(model.snapshots.count == 2 && model.snapshots[0].preset?.payload == baseline.payload)
        let drive = model.catalog!.effect(106)!.parameters.first { $0.id == 1 }!
        model.set(drive,raw:150); drain(); precondition(model.undoValues.count == 1)
        model.compareSnapshot(model.snapshots[0]); drain()
        precondition(model.comparison.count == 1 && model.comparison[0].id == "106:1")
        model.undoLast(); drain(); precondition(device.payload == baseline.payload && model.undoValues.isEmpty)
        model.redoChange(); drain(); precondition(device.effectParameters[106]?[1] == 150)
        model.undoLast(); drain(); precondition(device.payload == baseline.payload)
        model.redoChange(); drain()
        device = try device.renamed("Front panel change")
        let beforeStale = requests.count
        model.undoLast()
        RunLoop.main.run(until:Date().addingTimeInterval(0.2))
        precondition(model.errorMessage != nil && device.name == "Front panel change")
        precondition(requests.dropFirst(beforeStale).allSatisfy { $0[5] == 3 })
        model.errorMessage = nil; device = baseline; model.refreshPreset(); drain()
        print("PASS snapshot, parameter undo/redo and stale front-panel history protection")
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
        var globalsPayload = baseline.payload
        var globalsOffset = 130
        while globalsPayload[globalsOffset] != 0 { globalsOffset += 2 + Int(globalsPayload[globalsOffset+1]) }
        globalsPayload.replaceSubrange(globalsOffset..<(globalsOffset+7),with:[139,4,50,127,127,127,0])
        let globalsBaseline = try baseline.replacingPayload(globalsPayload)
        device = globalsBaseline; model.apply(device)
        let count = requests.count
        model.selectEffect(139); drain(); precondition(requests.count == count && model.selectedControlsWritable)
        let gate = model.catalog!.effect(139)!.parameters.first { $0.id == 0 }!
        model.set(gate,raw:1); drain()
        precondition(device.effectParameters[139]?[0] == 1)
        precondition(requests.dropFirst(count).allSatisfy { $0[5] != 2 })
        model.undoLast(); drain(); precondition(device.payload == globalsBaseline.payload)
        device = baseline; model.apply(device)
        print("PASS preset globals use complete verified transfers without direct global queries")
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
        model.moveBlock(from:ampCell,to:emptyCell); drain()
        model.set(drive,raw:150); drain()
        precondition(model.gridUndo.isEmpty && model.gridRedo.isEmpty,"Routing-only history must not discard subsequent parameter changes")
        model.undoLast(); drain(); precondition(device.cells[emptyCell].effect == 106 && device.effectParameters[106]?[1] == baseline.effectParameters[106]?[1])
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
        let cachedRestart = EditorModel(storageRoot:directory,offline:true)
        precondition(cachedRestart.devicePresets.count == 7 && cachedRestart.devicePresets[383]?.preset?.storedSlot == 383, "Completed reads must survive restart")
        let previewRequests = requests.count
        cachedRestart.previewDeviceSlot(130)
        precondition(cachedRestart.presetName == "Slot 130" && !cachedRestart.connected && requests.count == previewRequests, "Cached previews require no MIDI")
        model.copyDeviceSlot(130); precondition(model.library.last?.source.contains("130") == true)
        model.readDeviceSlots([1,2,3]); model.stopDeviceRead(); drain()
        precondition(storedReads == 8 && model.devicePresets[1] == nil && !model.readingDevice)
        print("PASS stored bank boundaries, address matching, duplicate names, cancellation and no writes")
        // Library navigation must recall real slots, including both bank boundaries.
        model.librarySearch = ""
        precondition(model.adjacentLibraryItem([127,128],selected:127,direction:1) == 128)
        precondition(model.adjacentLibraryItem([0,1],selected:0,direction:-1) == nil)
        precondition(model.adjacentLibraryItem([0,1],selected:nil,direction:1) == 0)
        precondition(model.adjacentLibraryItem([0,1],selected:99,direction:-1) == 1)
        precondition(model.adjacentLibraryItem([Int](),selected:nil,direction:1) == nil)
        func fixture(_ payload:[UInt8]) throws -> UltraPreset {
            try UltraPreset(message:UltraProtocol.modernHeader+[4,1,0,0]+payload.flatMap { UltraProtocol.nibbles(Int($0)) }+UltraProtocol.nibbles(Int(payload.reduce(0,^)))+[247])
        }
        var legacyAmp = baseline.payload
        let ampOffset = 130
        precondition(legacyAmp[ampOffset] == 106 && legacyAmp[ampOffset+1] == 39)
        legacyAmp[ampOffset+13] = 254
        legacyAmp.remove(at:ampOffset+40); legacyAmp.append(0); legacyAmp[ampOffset+1] = 38
        let oldAmp = try fixture(legacyAmp)
        legacyAmp[ampOffset+13] = 216; legacyAmp.insert(127,at:ampOffset+40); legacyAmp.removeLast(); legacyAmp[ampOffset+1] = 39
        precondition(model.recalledPresetMatches(try! fixture(legacyAmp),stored:oldAmp))
        legacyAmp[ampOffset+3] ^= 1
        precondition(model.recalledPresetMatches(try! fixture(legacyAmp),stored:oldAmp))
        var blank = [UInt8](repeating:0,count:1024)
        blank.replaceSubrange(130..<136,with:[139,4,51,112,127,127])
        let storedBlank = try fixture(blank)
        blank[136] = 140; blank[137] = 13; blank[151] = 141; blank[152] = 55
        precondition(model.recalledPresetMatches(try! fixture(blank),stored:storedBlank))
        blank[34] = 106; precondition(!model.recalledPresetMatches(try! fixture(blank),stored:storedBlank)); blank[34] = 0
        blank[2] = 65; precondition(!model.recalledPresetMatches(try! fixture(blank),stored:storedBlank)); blank[2] = 0
        blank[151] = 106; precondition(!model.recalledPresetMatches(try! fixture(blank),stored:storedBlank))
        let switchesStart = requests.count
        for slot in [127,128,255,256,383] {
            model.activateDeviceSlot(slot)
            let during = requests.count
            model.activateDeviceSlot(12) // Repeated activation cannot enqueue a second switch.
            precondition(requests.count == during)
            drain()
            precondition(device.name == "Slot \(slot)" && model.presetNumber == slot && model.selectedLibrarySlot == slot)
            precondition(model.currentPreset?.payload == device.payload && !model.librarySwitching && !model.dirty)
        }
        precondition(requests.dropFirst(switchesStart).allSatisfy { $0.count < 6 || $0[5] == 3 },"Navigation must not upload or store presets")
        model.librarySearch = "Slot 12"
        precondition(model.visibleDeviceSlots(bank:-1) == [127,128])
        model.selectedLibrarySlot = 127; model.navigateDeviceLibrary(1,bank:-1); drain()
        precondition(model.presetNumber == 128)
        model.navigateDeviceLibrary(-1,bank:-1); drain(); precondition(model.presetNumber == 127)
        model.librarySearch = "130"; precondition(model.visibleDeviceSlots(bank:2) == [130])
        model.librarySearch = ""
        let previous = device
        ignoreNextProgram = true; model.activateDeviceSlot(256)
        let mismatchDeadline = Date().addingTimeInterval(6)
        while model.librarySwitching && Date() < mismatchDeadline { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
        precondition(model.errorMessage?.contains("recall readback differs") == true && !model.librarySwitching)
        precondition(model.snapshots.first?.preset?.payload == previous.payload)
        model.errorMessage = nil
        let macA = SavedPreset(preset:try baseline.renamed("A local"),source:"QA",favorite:true)
        let macB = SavedPreset(preset:try baseline.renamed("B local"),source:"QA",favorite:true)
        let savedLibrary = model.library
        model.library = [macB,macA]; model.favoritesOnly = true
        model.activateMacPreset(macA); drain(); precondition(device.name == "A local" && model.inspectedLibrary == nil)
        model.navigateMacLibrary(1); drain(); precondition(device.name == "B local" && model.selectedMacPreset == macB.id)
        model.navigateMacLibrary(-1); drain(); precondition(device.name == "A local")
        let beforePreview = requests.count
        model.previewMacPreset(macB); precondition(requests.count == beforePreview && device.name == "A local" && model.inspectedLibrary == macB.id)
        model.library = savedLibrary; model.favoritesOnly = false; model.inspectedLibrary = nil
        model.restoreForTest(baseline); drain()
        print("PASS library recall across banks, filtered Previous/Next, duplicate suppression, mismatch recovery and Mac activation")
        model.selectEffect(106); drain()
        model.readModifierOverview(); drain()
        precondition(!model.modifierAssignments.isEmpty && !model.modifierScanning)
        let target = model.modifierAssignments.first { $0.effect == 106 }!.parameter
        model.readModifier(target); drain()
        let modifierStart = requests.count
        let shape = ModifierSetting(title:"QA shape",fields:[0:1,1:0,2:127,3:254,4:100,5:20,10:0,11:0,12:0])
        model.applyModifierSetting(shape); drain()
        let operations = requests.dropFirst(modifierStart).filter { $0[5] == 7 }
        precondition(operations.count == 18)
        precondition(operations.filter { $0[14] == 1 }.map { UltraProtocol.byte($0[10],$0[11]) } == [0,1,2,3,4,5,10,11,12])
        precondition(model.modifierValues.mapValues { $0.0 } == shape.fields)
        model.saveModifierSetting("QA shape")
        precondition(EditorModel(storageRoot:directory,offline:true).modifierSettings.count == 1)
        model.modifierTarget = nil
        print("PASS modifier overview, source-first preset application, independent field queries and persistence")
        let offlineStart = requests.count
        let bankPresets = try UltraPreset.readFile(Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/Synthetic_BankA.syx")))
        model.changeBank(try BankWorkspace(presets:bankPresets))
        model.editBank(from:0,to:3,mode:0); precondition(model.bankWorkspace.preset(3)?.payload == bankPresets[0].payload)
        model.travelBank(redo:false); precondition(model.bankWorkspace.preset(0)?.payload == bankPresets[0].payload)
        model.travelBank(redo:true); precondition(model.bankWorkspace.preset(3)?.payload == bankPresets[0].payload)
        model.renameBank(slot:3,name:String(repeating:"x",count:21)); precondition(model.errorMessage != nil)
        model.renameBank(slot:3,name:"Bank test"); precondition(model.bankWorkspace.preset(3)?.name == "Bank test" && model.errorMessage == nil)
        let incomingURL = directory.appendingPathComponent("import.syx")
        try Data(baseline.renamed("Imported test").message).write(to:incomingURL)
        model.importFiles([incomingURL],folder:"Session")
        let libraryCount = model.library.count
        model.importFiles([incomingURL],folder:"Session"); precondition(model.library.count == libraryCount)
        precondition(model.organization.recentFiles.first == incomingURL.path)
        let organizationRestart = EditorModel(storageRoot:directory,offline:true)
        precondition(organizationRestart.organization.folders == ["Session"])
        let badURL = directory.appendingPathComponent("broken.syx"); try Data([0,1,2]).write(to:badURL)
        model.importFiles([incomingURL,badURL]); precondition(model.errorMessage != nil && model.library.count == libraryCount)
        model.errorMessage = nil
        precondition(requests.count == offlineStart)
        print("PASS bank history, file imports, deduplication, folder persistence and failed-import atomicity without MIDI")
        let beforeCancel = requests.count
        model.updateLive(drive,raw:150); model.updateLive(drive,raw:149); model.endLiveEdit(after:0.15)
        model.disconnect()
        RunLoop.main.run(until:Date().addingTimeInterval(0.2))
        precondition(requests.count == beforeCancel+1 && model.liveKey == nil && device.effectParameters[106]?[1] == 150)
        // An already submitted packet cannot be recalled; deferred target 149 must never send.
        device = baseline
        print("PASS disconnect cancels delayed live writes and stale gesture completion")
        let cancelModel = EditorModel(storageRoot:directory.appendingPathComponent("cancel-navigation"),offline:true)
        var cancelledPrograms = 0, cancelledBank = false
        cancelModel.attachTestTransport { bytes in
            if bytes[0] & 0xF0 == 0xB0 { cancelledBank = true; cancelModel.disconnect(); return }
            if bytes[0] & 0xF0 == 0xC0 { cancelledPrograms += 1; return }
            let reply = bytes[6] == 1 ? baseline.forEditBuffer() : try baseline.forStorage(slot:128)
            DispatchQueue.main.asyncAfter(deadline:.now()+0.002) { cancelModel.receiveTestMessage(reply) }
        }
        cancelModel.activateDeviceSlot(128)
        RunLoop.main.run(until:Date().addingTimeInterval(0.6))
        precondition(cancelledBank && cancelledPrograms == 0 && !cancelModel.librarySwitching)
        print("PASS disconnect between bank select and program change cancels delayed recall")
        let lostModel = EditorModel(storageRoot:directory.appendingPathComponent("lost-heartbeat"),offline:true)
        lostModel.attachTestTransport { _ in }
        lostModel.ping()
        precondition(lostModel.connected && lostModel.busy == 0)
        RunLoop.main.run(until:Date().addingTimeInterval(1.7))
        precondition(!lostModel.connected && lostModel.status.contains("Connection lost"), "Silent probes must still detect a lost connection")
        print("PASS silent health probe still detects connection loss")
        let cacheRoot = directory.appendingPathComponent("cache-all")
        let cacheModel = EditorModel(storageRoot:cacheRoot,offline:true)
        for slot in 0..<384 {
            cacheModel.cacheDevicePreset(try UltraPreset(message:baseline.renamed("Cached \(slot)").forStorage(slot:slot)),slot:slot)
        }
        let allCached = EditorModel(storageRoot:cacheRoot,offline:true)
        precondition(allCached.devicePresets.count == 384 && allCached.deviceCacheDate != nil)
        precondition(allCached.devicePresets[130]?.title == "Cached 130" && allCached.devicePresets[383]?.preset?.storedSlot == 383)
        allCached.disconnect(); precondition(allCached.devicePresets.count == 384)
        allCached.channel = 2; allCached.selectDeviceCache(); precondition(allCached.devicePresets.isEmpty, "Different MIDI connections must not reuse another profile")
        allCached.channel = 1; allCached.selectDeviceCache(); precondition(allCached.devicePresets.count == 384)
        let refreshed = try UltraPreset(message:baseline.renamed("Refreshed 130").forStorage(slot:130))
        allCached.cacheDevicePreset(refreshed,slot:130)
        precondition(EditorModel(storageRoot:cacheRoot,offline:true).devicePresets[130]?.title == "Refreshed 130")
        let badCacheURL = allCached.deviceCacheURL(slot:5,profile:allCached.deviceCacheProfile!)
        try Data("broken".utf8).write(to:badCacheURL)
        let damagedCache = EditorModel(storageRoot:cacheRoot,offline:true)
        precondition(damagedCache.devicePresets.count == 383 && damagedCache.devicePresets[5] == nil && damagedCache.deviceCacheWarning != nil)
        damagedCache.cacheDevicePreset(try UltraPreset(message:baseline.forStorage(slot:5)),slot:5)
        let repairedCache = EditorModel(storageRoot:cacheRoot,offline:true)
        precondition(repairedCache.devicePresets.count == 384 && repairedCache.deviceCacheWarning == nil)
        print("PASS all 384 cached slots persist, offline preview, connection isolation, refresh and corrupt-slot recovery")
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
        print("23 editor integration groups passed")
    }
}
