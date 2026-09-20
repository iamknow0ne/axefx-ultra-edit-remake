#if canImport(XCTest)
import XCTest
#endif
import Foundation
#if !STANDALONE
@testable import UltraCore
#endif

final class GridTests: XCTestCase {
    func fixture() throws -> UltraPreset { try UltraPreset(message:Array(Data(contentsOf:URL(fileURLWithPath:"Tests/Fixtures/synthetic-preset.syx")))) }
    func testMovePreservesSoundAndFanout() throws {
        let original = try fixture()
        let source = original.cells.first { $0.effect == 106 }!.id
        let target = source/4*4+(source%4+1)%4
        let moved = try original.editingGrid(.move(source:source,destination:target))
        XCTAssertEqual(moved.cells[target].effect,106); XCTAssertEqual(moved.cells[source].effect,0)
        XCTAssertEqual(moved.effectParameters,original.effectParameters)
        XCTAssertEqual(Array(moved.payload[130...]),Array(original.payload[130...]))
        XCTAssertEqual(Array(moved.payload[..<34]),Array(original.payload[..<34]))
        for link in original.gridLinks {
            let new = GridLink(source:link.source == source ? target : link.source,destination:link.destination == source ? target : link.destination)
            XCTAssertTrue(moved.gridLinks.contains(new))
        }
        XCTAssertEqual(try moved.editingGrid(.move(source:target,destination:source)).payload,original.payload)
        XCTAssertThrowsError(try original.editingGrid(.move(source:source,destination:12)))
        let detached = try original.editingGrid(.move(source:source,destination:12,detach:true))
        XCTAssertEqual(detached.cells[12].effect,106)
        XCTAssertFalse(detached.gridLinks.contains { $0.source == source || $0.destination == source })
    }
    func testSwapAndCableValidation() throws {
        let original = try fixture()
        let a = original.cells.first { $0.effect == 106 }!.id, b = original.cells.first { $0.effect == 108 }!.id
        let swapped = try original.editingGrid(.move(source:a,destination:b))
        XCTAssertEqual(swapped.cells[a].effect,108); XCTAssertEqual(swapped.cells[b].effect,106)
        XCTAssertEqual(swapped.gridLinks,original.gridLinks)
        XCTAssertEqual(swapped.effectParameters,original.effectParameters)
        XCTAssertEqual(try swapped.editingGrid(.move(source:b,destination:a)).payload,original.payload)
        let link = original.gridLinks.first!
        let removed = try original.editingGrid(.link(link,enabled:false))
        XCTAssertFalse(removed.gridLinks.contains(link))
        XCTAssertEqual(try removed.editingGrid(.link(link,enabled:true)).payload,original.payload)
        XCTAssertThrowsError(try original.editingGrid(.link(.init(source:47,destination:0),enabled:true)))
        XCTAssertThrowsError(try original.editingGrid(.link(.init(source:-1,destination:5),enabled:true)))
        XCTAssertThrowsError(try original.editingGrid(.link(.init(source:0,destination:4),enabled:true)))
        XCTAssertThrowsError(try removed.editingGrid(.reroute(link,to:link)))
        XCTAssertThrowsError(try original.editingGrid(.move(source:48,destination:0)))
    }
    func testStoredAddressesAndBankImport() throws {
        for slot in [0,127,128,130,255,256,383] {
            let query = try UltraProtocol.storedPreset(slot)
            XCTAssertEqual(query,UltraProtocol.modernHeader+[3,0,UInt8(slot & 15),UInt8(slot >> 4),0xF7])
            let stored = try UltraPreset(message:fixture().forStorage(slot:slot))
            XCTAssertEqual(stored.storedSlot,slot)
        }
        let cReply = try fixture().forStorage(slot:127)
        XCTAssertEqual(try UltraPreset.storedReply(cReply,requestedSlot:383).storedSlot,383)
        XCTAssertThrowsError(try UltraPreset.storedReply(cReply,requestedSlot:130))
        XCTAssertThrowsError(try UltraPreset.storedReply(fixture().forEditBuffer(),requestedSlot:256))
        XCTAssertThrowsError(try UltraProtocol.storedPreset(384)); XCTAssertThrowsError(try UltraProtocol.storedPreset(-1))
        for (bank,name) in ["A","B","C"].enumerated() {
            let presets = try UltraPreset.readFile(Data(contentsOf:URL(fileURLWithPath:"Tests/Fixtures/Synthetic_Bank\(name).syx")))
            XCTAssertEqual(presets.map(\.storedSlot),(bank*128..<bank*128+128).map { Optional($0) })
        }
    }
}
