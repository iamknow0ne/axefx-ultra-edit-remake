#if !STANDALONE
import XCTest
@testable import UltraCore
#else
import Foundation
#endif
final class UltraCoreTests: XCTestCase {
    func testFirmwareAndNameQueries() {
        XCTAssertEqual(UltraProtocol.firmware(),[0xF0,0,1,0x74,1,8,0,0,0xF7])
        XCTAssertEqual(UltraProtocol.name(),[0xF0,0,1,0x74,1,15,0xF7])
        XCTAssertEqual(UltraProtocol.patch(),[0xF0,0,1,0x74,1,3,1,0,0,0xF7])
        XCTAssertEqual(UltraProtocol.firmware(header:UltraProtocol.header(legacy:true)),[0xF0,0,0,125,1,8,0,0,0xF7])
    }
    func testGoldenParameterMessages() throws {
        XCTAssertEqual(try UltraProtocol.parameter(effect:106,parameter:1),[0xF0,0,1,0x74,1,2,10,6,1,0,0,0,0,0xF7])
        XCTAssertEqual(try UltraProtocol.parameter(effect:106,parameter:1,value:254),[0xF0,0,1,0x74,1,2,10,6,1,0,14,15,1,0xF7])
        XCTAssertThrowsError(try UltraProtocol.parameter(effect:256,parameter:1))
        XCTAssertThrowsError(try UltraProtocol.parameter(effect:106,parameter:1,value:255))
        let bytes: [UInt8] = [0xF0,0,1,0x74,1,2,10,6,1,0,15,7,53,46,48,48,0,0xF7]
        let parsed = try XCTUnwrap(UltraProtocol.response(bytes))
        XCTAssertEqual(parsed.effect,106); XCTAssertEqual(parsed.parameter,1); XCTAssertEqual(parsed.raw,127); XCTAssertEqual(parsed.text,"5.00")
        var wrong = bytes; wrong[4] = 3; XCTAssertNil(UltraProtocol.response(wrong))
        wrong = bytes; wrong[7] = 16; XCTAssertNil(UltraProtocol.response(wrong))
        for i in 0..<14 { XCTAssertNil(UltraProtocol.response(Array(bytes.prefix(i)))) }
    }
    func testOriginalBinaryPlacementFormatOmitsQueryByte() throws {
        XCTAssertEqual(try UltraProtocol.place(effect:106,position:5),[0xF0,0,1,0x74,1,5,10,6,5,0xF7])
        XCTAssertThrowsError(try UltraProtocol.place(effect:106,position:48))
        XCTAssertEqual(try UltraProtocol.connect(source:1,destination:6,enabled:true),[0xF0,0,1,0x74,1,6,1,6,1,0xF7])
        XCTAssertThrowsError(try UltraProtocol.connect(source:1,destination:10,enabled:true))
    }
    func testFramerHandlesFragmentationRealtimeAndResynchronization() {
        var parser = SysExFramer()
        XCTAssertEqual(parser.feed([0xF0,0,1,0xF8,0x74]),[])
        XCTAssertEqual(parser.feed([1,8,11,0,0xF7]),[UltraProtocol.modernHeader + [8,11,0,0xF7]])
        XCTAssertEqual(parser.feed([0xF0,0,1,0x90,60,127,0xF7]),[])
        XCTAssertEqual(parser.feed([0xF0,5,0xF0,6,0xF7,0xF0,7,0xF7]),[[0xF0,6,0xF7],[0xF0,7,0xF7]])
    }
    func testProgramBanksAndNameBounds() throws {
        XCTAssertEqual(try UltraProtocol.program(383,channel:16),[[0xBF,0,2],[0xCF,127]])
        XCTAssertThrowsError(try UltraProtocol.program(-1,channel:1))
        XCTAssertThrowsError(try UltraProtocol.program(384,channel:1))
        XCTAssertThrowsError(try UltraProtocol.program(1,channel:0))
        XCTAssertEqual(try UltraProtocol.rename("Lead").count,30)
        XCTAssertThrowsError(try UltraProtocol.rename("Too long a preset name here"))
        XCTAssertThrowsError(try UltraProtocol.rename("Métał"))
    }
    func testPresetRoundTripAndChecksumRejection() throws {
        var payload = [UInt8](repeating:0,count:1024)
        payload[0] = 53; payload[2..<22] = Array("Test preset         ".utf8)[...]
        payload[34] = 106; payload[35] = 2; payload[42] = 108; payload[43] = 2
        var message: [UInt8] = UltraProtocol.modernHeader + [4,1,0,0]
        message += payload.flatMap { UltraProtocol.nibbles(Int($0)) }; message += UltraProtocol.nibbles(Int(payload.reduce(0,^))); message += [0xF7]
        let preset = try UltraPreset(message:message)
        let renamed = try preset.renamed("New name")
        XCTAssertEqual(renamed.name,"New name")
        XCTAssertEqual(Array(renamed.payload[22...]),Array(preset.payload[22...]))
        XCTAssertEqual(Array(renamed.payload[..<2]),Array(preset.payload[..<2]))
        XCTAssertThrowsError(try preset.renamed("Invalid name too long to fit"))
        XCTAssertEqual(preset.name,"Test preset"); XCTAssertEqual(preset.cells[0].effect,106)
        XCTAssertEqual(preset.cells[4].inputMask,2)
        XCTAssertEqual(try UltraPreset(message:preset.forEditBuffer()).payload,payload)
        XCTAssertEqual(Array(try preset.forStorage(slot:383)[6..<9]),[0,127,23])
        XCTAssertEqual(try UltraPreset(message:preset.forStorage(slot:383)).payload,payload)
        var corrupt = message; corrupt[10] ^= 1; XCTAssertThrowsError(try UltraPreset(message:corrupt))
        XCTAssertThrowsError(try UltraPreset(message:Array(message.dropLast())))
        XCTAssertThrowsError(try UltraPreset.readFile(Data(message + [0xF0,0])))
    }
    func testCatalogAndSyntheticBanks() throws {
        let root = URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let catalog = try Catalog(url:root.appendingPathComponent("Resources/UltraCatalog.json"))
        XCTAssertEqual(catalog.effects.count,36)
        XCTAssertEqual(catalog.effect(106)?.typeParameterID,0)
        XCTAssertEqual(UltraProtocol.status([0xF0,0,1,0x74,1,0x0B,4,1,0xF7],for:4),1)
        XCTAssertNil(UltraProtocol.status([0xF0,0,1,0x74,1,0x0B,5,1,0xF7],for:4))
        XCTAssertEqual(catalog.effects.reduce(0) { $0 + $1.parameters.count },922)
        XCTAssertEqual(catalog.effect(106)?.parameters.first { $0.id == 1 }?.name,"Drive")
        XCTAssertFalse(catalog.effect(106)!.parameters.contains { $0.id == 205 })
        let pitch = try XCTUnwrap(catalog.effect(130)?.parameters.first { $0.id == 10 })
        XCTAssertEqual(pitch.rawMinimum,103); XCTAssertEqual(pitch.rawMaximum,151); XCTAssertEqual(pitch.estimate(127),"0")
        let banks = root.appendingPathComponent("Tests/Fixtures")
        var count = 0
        for name in ["Synthetic_BankA.syx","Synthetic_BankB.syx","Synthetic_BankC.syx"] {
            let presets = try UltraPreset.readFile(Data(contentsOf:banks.appendingPathComponent(name)))
            XCTAssertEqual(presets.count,128)
            for preset in presets { XCTAssertEqual(try UltraPreset(message:preset.forEditBuffer()).payload,preset.payload); XCTAssertEqual(preset.cells.count,48); count += 1 }
        }
        XCTAssertEqual(count,384)
    }
    func testQueueRejectsUnmatchedResponseAndCancelsPendingSend() {
        let done = expectation(description:"correct reply")
        var sent: [[UInt8]] = []
        let queue = RequestQueue { sent.append($0) }
        queue.enqueue(.init(bytes:[1],timeout:0.3,matches:{ $0 == [2] }) { result in XCTAssertEqual(try? result.get(),[2]); done.fulfill() })
        DispatchQueue.main.asyncAfter(deadline:.now()+0.02) { queue.receive([9]); XCTAssertEqual(queue.count,1); queue.receive([2]) }
        wait(for:[done],timeout:1)
        XCTAssertEqual(sent,[[1]])
        queue.enqueue(.init(bytes:[3],matches:{_ in true}) { _ in XCTFail("Cancelled callback must not run") })
        queue.enqueue(.init(bytes:[4],matches:{_ in true}) { _ in XCTFail("Pending callback must not run") })
        queue.cancel()
        let drained = expectation(description:"drained")
        DispatchQueue.main.asyncAfter(deadline:.now()+0.08) { XCTAssertEqual(sent,[[1],[3]]); drained.fulfill() }
        wait(for:[drained],timeout:1)
    }
    func testQueueTimeoutDoesNotRetryWrite() {
        let done = expectation(description:"timeout")
        var sends = 0
        let queue = RequestQueue { _ in sends += 1 }
        queue.enqueue(.init(bytes:[0xF0,1,0xF7],timeout:0.03,matches:{ _ in false }) { result in if case .success = result { XCTFail("Expected timeout") }; done.fulfill() })
        wait(for:[done],timeout:1); XCTAssertEqual(sends,1); XCTAssertEqual(queue.count,0)
    }
    func testSnapshotDiffPersistenceAndSearch() throws {
        let root = URL(fileURLWithPath:#filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
        let catalog = try Catalog(url:root.appendingPathComponent("Resources/UltraCatalog.json"))
        let baseline = try UltraPreset(message:Array(Data(contentsOf:root.appendingPathComponent("Tests/Fixtures/synthetic-preset.syx"))))
        func make(_ payload: [UInt8]) throws -> UltraPreset {
            try UltraPreset(message:UltraProtocol.modernHeader + [4,1,0,0] + payload.flatMap { UltraProtocol.nibbles(Int($0)) } + UltraProtocol.nibbles(Int(payload.reduce(0,^))) + [0xF7])
        }
        XCTAssertTrue(baseline.changes(from:baseline,catalog:catalog).isEmpty)
        var bytes = baseline.payload
        bytes[133] = bytes[133] == 0 ? 1 : bytes[133]-1
        let changed = try make(bytes)
        let differences = changed.changes(from:baseline,catalog:catalog)
        XCTAssertEqual(differences.count,1); XCTAssertEqual(differences.first?.id,"106:1")
        XCTAssertFalse(changed.fingerprint == baseline.fingerprint)
        bytes = baseline.payload; bytes[34] = 200; bytes[35] = 2; bytes[2] = 88; bytes[1023] ^= 1
        let structural = try make(bytes).changes(from:baseline,catalog:catalog)
        XCTAssertTrue(structural.contains(where:{$0.id == "name"})); XCTAssertTrue(structural.contains(where:{$0.id == "cell:0"})); XCTAssertTrue(structural.contains(where:{$0.id == "opaque"}))
        let entry = SavedPreset(preset:baseline,title:"Clean favorite",source:"My bank",favorite:true)
        XCTAssertTrue(entry.matches("clean",catalog:catalog)); XCTAssertTrue(entry.matches("amp",catalog:catalog)); XCTAssertFalse(entry.matches("gibberish",catalog:catalog))
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathComponent("snapshots.json")
        defer { try? FileManager.default.removeItem(at:url.deletingLastPathComponent()) }
        try PresetArchive.save([entry],to:url)
        let loaded = try PresetArchive.load(url)
        XCTAssertEqual(loaded.first?.preset?.payload,baseline.payload); XCTAssertEqual(loaded.first?.id,entry.id); XCTAssertEqual(loaded.first?.favorite,true)
        try Data("invalid json".utf8).write(to:url)
        XCTAssertThrowsError(try PresetArchive.load(url))
        XCTAssertEqual(String(data:try Data(contentsOf:url),encoding:.utf8),"invalid json")
    }
    func testMultipartFailureDoesNotLeakIntoNextRequest() {
        var sends = 0
        let queue = RequestQueue { _ in sends += 1; if sends == 2 { throw MIDIError.message("Disconnected") } }
        let failed = expectation(description:"multipart failure")
        queue.enqueue(.init(bytes:Array(repeating:1,count:400),timeout:0.1,matches:{_ in false}) { result in
            if case .success = result { XCTFail("Expected failure") }; failed.fulfill()
        })
        wait(for:[failed],timeout:1)
        let done = expectation(description:"no late chunks")
        DispatchQueue.main.asyncAfter(deadline:.now()+0.25) { XCTAssertEqual(sends,2); done.fulfill() }
        wait(for:[done],timeout:1)
    }

    func testNativeLongTransferSettlesBeforeNextRequest() {
        var shortSends = 0, longSends = 0, acknowledged: Date?, nextSent: Date?
        let queue = RequestQueue(sendLong:{ bytes in XCTAssertEqual(bytes.count,2060); longSends += 1 }) { _ in shortSends += 1; nextSent = Date() }
        let done = expectation(description:"settled transfer")
        queue.enqueue(.init(bytes:Array(repeating:0,count:2060),timeout:1,matches:{$0 == [4]}) { _ in acknowledged = Date() })
        queue.enqueue(.init(bytes:[3],timeout:1,matches:{$0 == [3]}) { _ in done.fulfill() })
        DispatchQueue.main.asyncAfter(deadline:.now()+0.05) { queue.receive([4]) }
        DispatchQueue.main.asyncAfter(deadline:.now()+0.3) { XCTAssertEqual(shortSends,0) }
        DispatchQueue.main.asyncAfter(deadline:.now()+0.95) { queue.receive([3]) }
        wait(for:[done],timeout:2)
        XCTAssertEqual(longSends,1); XCTAssertEqual(shortSends,1)
        XCTAssertTrue(nextSent!.timeIntervalSince(acknowledged!) >= 0.75)
    }

}
