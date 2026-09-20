import Foundation

/// One transaction at a time; no retry of writes. All calls run on the main queue.
public final class RequestQueue {
    public enum Priority: Int { case background, normal, interactive }
    public struct Request {
        let blocksInterface: Bool
        let priority: Priority
        let bytes: [UInt8]
        let timeout: TimeInterval
        let matches: ([UInt8]) -> Bool
        let completion: (Result<[UInt8], Error>) -> Void
        public init(bytes: [UInt8], timeout: TimeInterval = 1.5, priority: Priority = .normal, blocksInterface: Bool = true, matches: @escaping ([UInt8]) -> Bool, completion: @escaping (Result<[UInt8], Error>) -> Void) {
            self.blocksInterface = blocksInterface; self.priority = priority; self.bytes = bytes; self.timeout = timeout; self.matches = matches; self.completion = completion
        }
    }
    private var pending: [Request] = []
    private var active: Request?
    private var timer: Timer?
    private var generation = 0
    private var cooling = false
    private var coolingForeground = false
    private var coolingBlocksInterface = false
    public let send: ([UInt8]) throws -> Void
    public let sendLong: (([UInt8]) throws -> Void)?
    public var onActivity: ((Int) -> Void)?
    /// User-facing work only; health probes still use the serialized queue.
    public var onInterfaceActivity: ((Int) -> Void)?
    public var onSent: (([UInt8]) -> Void)?
    private let shortGap: TimeInterval
    public var hasForegroundWork: Bool { active.map { $0.priority != .background } == true || pending.contains { $0.priority != .background } || (cooling && coolingForeground) }
    public var count: Int { pending.count + (active == nil ? 0 : 1) }
    public init(shortGap: TimeInterval = 0, sendLong: (([UInt8]) throws -> Void)? = nil, send: @escaping ([UInt8]) throws -> Void) { self.shortGap = shortGap; self.send = send; self.sendLong = sendLong }
    public func enqueue(_ request: Request) {
        let index = pending.firstIndex { $0.priority.rawValue < request.priority.rawValue } ?? pending.endIndex
        pending.insert(request, at:index); advance()
    }
    public func receive(_ bytes: [UInt8]) {
        guard let request = active, request.matches(bytes) else { return }
        finish(.success(bytes))
    }
    public func cancel() {
        generation += 1; timer?.invalidate(); timer = nil; active = nil; pending.removeAll(); cooling = false; notifyActivity()
    }
    private func notifyActivity() {
        onActivity?(count + (cooling ? 1 : 0))
        onInterfaceActivity?(pending.filter { $0.blocksInterface }.count + (active?.blocksInterface == true ? 1 : 0) + (cooling && coolingBlocksInterface ? 1 : 0))
    }
    private func advance() {
        notifyActivity()
        guard active == nil, !cooling, !pending.isEmpty else { return }
        let request = pending.removeFirst(); active = request
        let token = generation
        if request.bytes.count <= 128 {
            // Submit short controls in this event turn, before SwiftUI gets a
            // chance to rebuild the window. MIDISend only queues the packet.
            timer = makeTimer(interval:request.timeout) { [weak self] _ in
                guard let self, self.generation == token else { return }
                self.finish(.failure(MIDIError.message("No reply from the Ultra. Check both MIDI cables and SysEx settings.")))
            }
            onSent?(request.bytes)
            do { try send(request.bytes) } catch { finish(.failure(error)) }
            return
        }
        if request.bytes.count > 256, let sendLong {
            onSent?(request.bytes)
            timer = makeTimer(interval: Double(request.bytes.count)*0.00032 + request.timeout) { [weak self] _ in
                guard let self, self.generation == token else { return }
                self.finish(.failure(MIDIError.message("No reply after preset transfer. Your recovery snapshot is retained.")))
            }
            do { try sendLong(request.bytes) } catch { finish(.failure(error)) }
            return
        }
        // DIN MIDI is 31.25 kbit/s. 128-byte chunks at 60 ms leave headroom.
        let chunks = stride(from: 0, to: request.bytes.count, by: 128).map { Array(request.bytes[$0..<min($0+128,request.bytes.count)]) }
        for (index, chunk) in chunks.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index)*0.06) { [weak self] in
                guard let self, self.generation == token, self.active != nil else { return }
                do { try self.send(chunk) } catch { self.finish(.failure(error)) }
            }
        }
        onSent?(request.bytes)
        timer = makeTimer(interval: Double(max(0,chunks.count-1))*0.06 + request.timeout) { [weak self] _ in
            guard let self, self.generation == token else { return }
            self.finish(.failure(MIDIError.message("No reply from the Ultra. Check both MIDI cables and SysEx settings.")))
        }
    }
    private func makeTimer(interval: TimeInterval, action: @escaping (Timer) -> Void) -> Timer {
        let timer = Timer(timeInterval:interval, repeats:false, block:action)
        RunLoop.main.add(timer, forMode:.common)
        return timer
    }
    private func finish(_ result: Result<[UInt8], Error>) {
        guard let request = active else { return }
        timer?.invalidate(); timer = nil; active = nil
        generation += 1; cooling = true
        let storedRead = request.bytes.count == 10 && request.bytes[5] == 3 && request.bytes[6] != 1
        // Gen-1 reuses a transfer buffer for stored reads. An immediate patch
        // query can return that temporary preset instead of the active sound.
        let settling: TimeInterval = storedRead ? 1.0 : request.bytes.count > 256 ? 0.8 : shortGap
        coolingBlocksInterface = request.blocksInterface
        coolingForeground = request.priority != .background || request.bytes.count > 256 || storedRead
        let token = generation
        request.completion(result)
        notifyActivity()
        guard generation == token else { return }
        if settling == 0 {
            cooling = false; advance(); return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + settling) { [weak self] in
            guard let self, self.generation == token else { return }
            self.cooling = false; self.advance()
        }
    }
}
