import Foundation

/// One gesture, one outstanding transaction, and one replaceable target.
/// Intermediate values use SET acknowledgements; the final value gets a GET.
/// Main-thread only. Never retries a failed write.
public final class LiveParameterEdit {
    public let key: String
    public private(set) var target: Int
    private let effect: Int, parameter: Int
    private let header: [UInt8], queue: RequestQueue
    private var acknowledged: Int
    private var inFlight = false, ended = false, cancelled = false
    private var lastSend = -Double.infinity
    private var wake: DispatchWorkItem?
    public var onAcknowledged: ((ParameterValue) -> Void)?
    public var completion: ((Result<ParameterValue, Error>) -> Void)?

    public init(effect: Int, parameter: Int, initial: Int, header: [UInt8], queue: RequestQueue) {
        self.effect = effect; self.parameter = parameter; self.header = header; self.queue = queue
        self.target = initial; self.acknowledged = initial; self.key = "\(effect):\(parameter)"
    }
    public func update(_ raw: Int) {
        guard !cancelled else { return }
        target = raw; ended = false; pump()
    }
    public func finish() { guard !cancelled else { return }; ended = true; pump() }
    public func cancel() { cancelled = true; wake?.cancel(); wake = nil }
    private func pump() {
        guard !cancelled, !inFlight else { return }
        wake?.cancel(); wake = nil
        if acknowledged == target {
            if ended { transact(value:nil) }
            return
        }
        // Bound DIN traffic to 50 writes/s, or the device's slower reply rate.
        let delay = max(0, 0.020 - (ProcessInfo.processInfo.systemUptime - lastSend))
        if delay > 0 {
            let work = DispatchWorkItem { [weak self] in self?.pump() }
            wake = work; DispatchQueue.main.asyncAfter(deadline:.now()+delay,execute:work)
        } else { transact(value:target) }
    }
    private func transact(value: Int?) {
        do {
            let bytes = try UltraProtocol.parameter(effect:effect,parameter:parameter,value:value,header:header)
            inFlight = true
            if value != nil { lastSend = ProcessInfo.processInfo.systemUptime }
            let queriedTarget = target
            queue.enqueue(.init(bytes:bytes,priority:.interactive,matches:{ [key] in UltraProtocol.response($0)?.key == key }) { [weak self] result in
                guard let self, !self.cancelled else { return }
                self.inFlight = false
                do {
                    guard let reply = UltraProtocol.response(try result.get()), reply.raw == (value ?? queriedTarget) else {
                        throw MIDIError.message("The Ultra did not confirm the requested value. Refresh before editing again.")
                    }
                    self.acknowledged = reply.raw
                    self.onAcknowledged?(reply)
                    if value == nil && self.ended && self.target == queriedTarget {
                        self.cancel(); self.completion?(.success(reply))
                    } else { self.pump() }
                } catch { self.cancel(); self.completion?(.failure(error)) }
            })
        } catch { cancel(); completion?(.failure(error)) }
    }
}
