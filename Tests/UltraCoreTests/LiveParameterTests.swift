#if !STANDALONE
import XCTest
@testable import UltraCore
#endif
import Foundation

final class LiveParameterTests: XCTestCase {
    func testShortSendDoesNotWaitForAnotherUIEventTurn() {
        var sent: [[UInt8]] = []
        let queue = RequestQueue { sent.append($0) }
        queue.enqueue(.init(bytes:[1],matches:{$0 == [1]}) { _ in })
        XCTAssertEqual(sent,[[1]])
        queue.enqueue(.init(bytes:[2],matches:{$0 == [2]}) { _ in })
        XCTAssertEqual(sent,[[1]])
        queue.receive([1])
        XCTAssertEqual(sent,[[1],[2]])
        queue.cancel()
    }
    func testFinalReadbackAndRetargetDuringVerification() throws {
        var queue: RequestQueue!, device = 100, writes: [Int] = [], reads = 0
        var edit: LiveParameterEdit!
        queue = RequestQueue { bytes in
            let isWrite = bytes[12] == 1
            if isWrite { device = UltraProtocol.byte(bytes[10],bytes[11]); writes.append(device) }
            else { reads += 1 }
            let reply = UltraProtocol.modernHeader + [2] + Array(bytes[6..<10]) + UltraProtocol.nibbles(device) + [0,0xF7]
            if !isWrite && reads == 1 {
                // A new pointer movement arrives while GET for the old target is in flight.
                edit.update(103); edit.finish()
            }
            DispatchQueue.main.asyncAfter(deadline:.now()+0.005) { queue.receive(reply) }
        }
        edit = LiveParameterEdit(effect:106,parameter:1,initial:100,header:UltraProtocol.modernHeader,queue:queue)
        let done = expectation(description:"Latest target independently read")
        edit.completion = { result in
            XCTAssertEqual(try? result.get().raw,103); done.fulfill()
        }
        edit.update(101); edit.update(102); edit.finish()
        wait(for:[done],timeout:1)
        XCTAssertEqual(writes,[101,102,103]); XCTAssertEqual(reads,2)
    }
    func testFailureStopsPendingGestureWithoutRetry() throws {
        var sends = 0, queue: RequestQueue!
        queue = RequestQueue { _ in sends += 1; throw MIDIError.message("Disconnected") }
        let edit = LiveParameterEdit(effect:106,parameter:1,initial:100,header:UltraProtocol.modernHeader,queue:queue)
        let done = expectation(description:"Failure reported")
        edit.completion = { result in
            if case .success = result { XCTFail("Unexpected success") }; done.fulfill()
        }
        edit.update(101); edit.update(102); edit.finish()
        wait(for:[done],timeout:1)
        edit.update(104); edit.finish()
        RunLoop.main.run(until:Date().addingTimeInterval(0.04))
        XCTAssertEqual(sends,1)
    }
    func testQueuePrioritizesEditsWithoutInterruptingActiveRead() throws {
        var queue: RequestQueue!, order: [UInt8] = []
        queue = RequestQueue { bytes in
            order.append(bytes[0])
            DispatchQueue.main.asyncAfter(deadline:.now()+0.003) { queue.receive(bytes) }
        }
        let done = expectation(description:"Background eventually drains")
        for (id,priority) in [(UInt8(1),RequestQueue.Priority.background),(2,.background),(3,.normal),(4,.interactive)] {
            queue.enqueue(.init(bytes:[id],priority:priority,matches:{ $0 == [id] }) { _ in if id == 2 { done.fulfill() } })
        }
        wait(for:[done],timeout:1)
        XCTAssertEqual(order,[1,4,3,2])
    }
}
