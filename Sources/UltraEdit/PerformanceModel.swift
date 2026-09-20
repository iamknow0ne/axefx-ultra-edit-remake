import AppKit
import UltraCore

extension EditorModel {
    var bypassParameter: ParameterDefinition? {
        activeEffect?.parameters.first { $0.key.hasSuffix("_BYPASS") || $0.key.hasSuffix("_FLAGS") }
    }
    var selectedBypassed: Bool {
        guard let p = bypassParameter, let raw = values["\(selectedEffect):\(p.id)"]?.raw else { return false }
        return raw & 1 != 0
    }
    func toggleBypass() {
        guard canOperate, !isPresetGlobal, let parameter = bypassParameter else { return }
        let effect = selectedEffect
        do {
            request(try UltraProtocol.parameter(effect:effect,parameter:parameter.id,header:header),match:{ UltraProtocol.response($0)?.key == "\(effect):\(parameter.id)" }) { [weak self] result in
                guard let self else { return }
                do {
                    guard let value = UltraProtocol.response(try result.get()) else { throw MIDIError.message("Invalid bypass flags") }
                    self.values[value.key] = value
                    // Defer until the query completion releases the queue.
                    DispatchQueue.main.async { guard self.selectedEffect == effect else { return }; self.set(parameter,raw:value.raw ^ 1) }
                } catch { self.fail(error) }
            }
        } catch { fail(error) }
    }
    func sendPerformanceCC(_ cc: Int, value: Int) {
        guard canOperate, performanceMappingConfirmed else { return }
        do { try sendController(cc,value:value) } catch { fail(error) }
    }
    func tapTempo() { sendPerformanceCC(tapCC,value:127); if canOperate && performanceMappingConfirmed { status = "Tempo tap sent • waiting for Ultra tempo pulses" } }
    func setTuner(_ enabled: Bool) {
        guard canOperate, performanceMappingConfirmed else { return }
        sendPerformanceCC(tunerCC,value:enabled ? 127 : 0)
        tunerCommandedOn = enabled
        if !enabled { tunerReading = nil; tunerAt = nil }
    }
    func receivePerformance(_ bytes: [UInt8]) -> Bool {
        if let reading = TunerReading(message:bytes) { tunerReading = reading; tunerAt = Date(); return true }
        if bytes[5] == 0x10 {
            let now = Date()
            if let last = tempoAt {
                let interval = now.timeIntervalSince(last)
                if interval >= 0.15 && interval <= 3 { observedBPM = 60/interval }
            }
            tempoAt = now
        }
        return false
    }
}
