import Foundation
#if !STANDALONE
import XCTest
@testable import UltraCore
#endif
final class ModernFeatureTests: XCTestCase {
    func testBankWorkspaceRoundTripAndAddressing() throws {
        let presets = try ["A","B","C"].flatMap { try UltraPreset.readFile(Data(contentsOf:URL(fileURLWithPath:"Tests/Fixtures/Synthetic_Bank\($0).syx"))) }
        var bank = try BankWorkspace(presets:presets)
        let exported = try UltraPreset.readFile(bank.export(banks:[0,1,2]))
        XCTAssertEqual(exported.count,384)
        for slot in 0..<384 { XCTAssertEqual(exported[slot].payload,presets[slot].payload); XCTAssertEqual(exported[slot].storedSlot,slot) }
        try bank.transfer(from:127,to:130)
        XCTAssertEqual(bank.preset(130)?.payload,presets[127].payload)
        XCTAssertEqual(bank.preset(127)?.payload,presets[128].payload)
        try bank.transfer(from:130,to:300,copy:true)
        XCTAssertEqual(bank.preset(300)?.storedSlot,300); XCTAssertEqual(bank.preset(300)?.payload,presets[127].payload)
        try bank.transfer(from:300,to:383,swap:true)
        XCTAssertEqual(bank.preset(300)?.payload,presets[383].payload)
        try bank.rename(383,name:"Local rename")
        XCTAssertEqual(bank.preset(383)?.name,"Local rename")
        XCTAssertThrowsError(try bank.transfer(from:0,to:384))
        XCTAssertThrowsError(try BankWorkspace().export(banks:[0]))
        XCTAssertThrowsError(try BankWorkspace(presets:[presets[0],presets[0]]))
    }
    func testNumericCabinetAndTunerBoundaries() throws {
        let catalog = try Catalog(url:URL(fileURLWithPath:"Resources/UltraCatalog.json"))
        let drive = try XCTUnwrap(catalog.effect(106)?.parameters.first { $0.id == 1 })
        XCTAssertEqual(try drive.rawValue(for:127,estimatedUnits:false),127)
        XCTAssertEqual(try drive.rawValue(for:drive.minimum,estimatedUnits:true),0)
        XCTAssertEqual(try drive.rawValue(for:drive.maximum,estimatedUnits:true),254)
        XCTAssertThrowsError(try drive.rawValue(for:.nan,estimatedUnits:false))
        XCTAssertThrowsError(try drive.rawValue(for:1.5,estimatedUnits:false))
        XCTAssertThrowsError(try drive.rawValue(for:255,estimatedUnits:false))
        let samples: [Double] = [0.5,-0.5,0.25,-1,1-1/2147483648.0]+Array(repeating:0,count:1019)
        let cab = try UserCabIR(samples:samples,sampleRate:48000), bytes = try cab.message(slot:10)
        XCTAssertEqual(bytes.count,8204); XCTAssertEqual(Array(bytes.prefix(9)),[240,0,1,116,1,10,9,0,0])
        XCTAssertEqual(Array(bytes[9..<17]),[0,0,0,0,0,0,0,4]) // +0.5 = Q31 0x40000000
        XCTAssertEqual(try UserCabIR(message:bytes).samples,samples)
        XCTAssertEqual(try UserCabIR(message:bytes).message(slot:10),bytes)
        var bad = bytes; bad[10] ^= 1; XCTAssertThrowsError(try UserCabIR(message:bad))
        XCTAssertThrowsError(try cab.message(slot:11))
        XCTAssertThrowsError(try UserCabIR(samples:Array(repeating:1,count:1024),sampleRate:48000))
        XCTAssertThrowsError(try UserCabIR(samples:samples,sampleRate:44100))
        let reading = try XCTUnwrap(TunerReading(message:UltraProtocol.modernHeader+[13,9,0,63,247]))
        XCTAssertEqual(reading.noteName,"A"); XCTAssertEqual(reading.cents,0)
        XCTAssertNil(TunerReading(message:UltraProtocol.modernHeader+[13,12,0,63,247]))
        XCTAssertNil(TunerReading(message:UltraProtocol.modernHeader+[13,9,0,247]))
        XCTAssertEqual(try UltraProtocol.controller(14,value:127,channel:16),[191,14,127])
    }
    func testStoredReadSettlesBeforeEditBufferQuery() throws {
        var sent: [[UInt8]] = []
        let queue = RequestQueue { sent.append($0) }
        queue.enqueue(.init(bytes:try UltraProtocol.storedPreset(300),matches:{ _ in true }) { _ in })
        queue.enqueue(.init(bytes:UltraProtocol.patch(),matches:{ _ in true }) { _ in })
        queue.receive([1])
        XCTAssertEqual(sent.count,1)
        RunLoop.main.run(until:Date().addingTimeInterval(0.1)); XCTAssertEqual(sent.count,1)
        RunLoop.main.run(until:Date().addingTimeInterval(1.0)); XCTAssertEqual(sent.count,2)
        queue.cancel()
    }
}
