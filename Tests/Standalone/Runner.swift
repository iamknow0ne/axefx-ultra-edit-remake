import Foundation
// A tiny assertion adapter keeps the same tests runnable with the Command Line
// Tools, which do not ship XCTest. Full Xcode can run the ordinary XCTest target.
struct CheckFailure: Error { let message: String }
final class Expectation { var fulfilled = false; func fulfill() { fulfilled = true } }
class XCTestCase {
    func expectation(description: String) -> Expectation { Expectation() }
    func wait(for expectations: [Expectation], timeout: Double) {
        let end = Date().addingTimeInterval(timeout)
        while expectations.contains(where:{ !$0.fulfilled }) && Date() < end { RunLoop.main.run(until:Date().addingTimeInterval(0.005)) }
        XCTAssertTrue(expectations.allSatisfy(\.fulfilled))
    }
}
func XCTAssertEqual<T: Equatable>(_ lhs: @autoclosure () throws -> T,_ rhs: @autoclosure () throws -> T,file: StaticString = #filePath,line: UInt = #line) {
    do { let a = try lhs(), b = try rhs(); if a != b { fatalError("\(file):\(line): \(a) != \(b)") } } catch { fatalError("\(file):\(line): \(error)") }
}
func XCTAssertTrue(_ value: @autoclosure () -> Bool,file: StaticString = #filePath,line: UInt = #line) { if !value() { fatalError("\(file):\(line): expected true") } }
func XCTAssertFalse(_ value: @autoclosure () -> Bool,file: StaticString = #filePath,line: UInt = #line) { XCTAssertTrue(!value(),file:file,line:line) }
func XCTAssertNil<T>(_ value: @autoclosure () -> T?,file: StaticString = #filePath,line: UInt = #line) { XCTAssertTrue(value() == nil,file:file,line:line) }
func XCTUnwrap<T>(_ value: T?) throws -> T { guard let value else { throw CheckFailure(message:"Unexpected nil") }; return value }
func XCTAssertThrowsError<T>(_ action: @autoclosure () throws -> T,file: StaticString = #filePath,line: UInt = #line) { do { _ = try action() } catch { return }; fatalError("\(file):\(line): expected error") }
func XCTFail(_ message: String) { fatalError(message) }
func XCTSkip(_ message: String) -> CheckFailure { CheckFailure(message:message) }
@main enum CheckRunner {
    static func main() throws {
        setbuf(stdout, nil)
        let suite = UltraCoreTests()
        let productivity = ProductivityTests()
        let live = LiveParameterTests()
        let grid = GridTests()
        let tests: [(String, () throws -> Void)] = [
            ("Bank workspace addressing, moves and complete exports",ModernFeatureTests().testBankWorkspaceRoundTripAndAddressing),
            ("Numeric, cabinet Q31 and tuner boundary validation",ModernFeatureTests().testNumericCabinetAndTunerBoundaries),
            ("Stored reads settle before the next edit-buffer query",ModernFeatureTests().testStoredReadSettlesBeforeEditBufferQuery),
            ("Grid moves preserve settings, opaque bytes and cables",grid.testMovePreservesSoundAndFanout),
            ("Grid swaps and cable validation",grid.testSwapAndCableValidation),
            ("All stored-address boundaries and imported bank slots",grid.testStoredAddressesAndBankImport),
            ("Short MIDI submits before the next UI event turn",live.testShortSendDoesNotWaitForAnotherUIEventTurn),
            ("Live final readback and retarget during verification",live.testFinalReadbackAndRetargetDuringVerification),
            ("Live failure cancels pending target without retry",live.testFailureStopsPendingGestureWithoutRetry),
            ("Live edits overtake background reads",live.testQueuePrioritizesEditsWithoutInterruptingActiveRead),
            ("Offline edits and effect copy preserve opaque data",productivity.testDraftAndEffectCopyPreserveUnknownBytes),
            ("Portable setlists retain presets and notes",productivity.testPortableSetlist),
            ("WAV parsing, resampling, blend, spectrum and rejection",productivity.testWAVAndImpulsePreparation),
            ("Firmware and legacy queries",suite.testFirmwareAndNameQueries),
            ("Golden parameter messages and malformed replies",suite.testGoldenParameterMessages),
            ("Binary-verified placement format",suite.testOriginalBinaryPlacementFormatOmitsQueryByte),
            ("Fragmentation and realtime MIDI",suite.testFramerHandlesFragmentationRealtimeAndResynchronization),
            ("Preset banks, channel and name boundaries",suite.testProgramBanksAndNameBounds),
            ("Preset round trip and checksum rejection",suite.testPresetRoundTripAndChecksumRejection),
            ("922 definitions and 384 synthetic bank presets",suite.testCatalogAndSyntheticBanks),
            ("Request identity and cancellation",suite.testQueueRejectsUnmatchedResponseAndCancelsPendingSend),
            ("Timeout never retries a write",suite.testQueueTimeoutDoesNotRetryWrite),
            ("Snapshot diff, archive persistence and search",suite.testSnapshotDiffPersistenceAndSearch),
            ("Multipart send failure cancels remaining chunks",suite.testMultipartFailureDoesNotLeakIntoNextRequest),
            ("Native full transfer and hardware settling interval",suite.testNativeLongTransferSettlesBeforeNextRequest)
        ]
        for (name,run) in tests { try run(); print("PASS \(name)") }
        print("\(tests.count) tests passed")
    }
}
