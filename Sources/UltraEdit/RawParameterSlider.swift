import SwiftUI
import AppKit

/// Integer MIDI precision without 255 expensive native tick marks.
struct RawParameterSlider: NSViewRepresentable {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let label: String
    let onEditingChanged: (Bool) -> Void
    @Environment(\.isEnabled) private var enabled
    init(value: Binding<Double>, in range: ClosedRange<Double>, label: String, onEditingChanged: @escaping (Bool) -> Void) {
        _value = value; self.range = range; self.label = label; self.onEditingChanged = onEditingChanged
    }
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeNSView(context: Context) -> IntegerSlider {
        let slider = IntegerSlider(frame:.zero)
        slider.isContinuous = true; slider.numberOfTickMarks = 0
        slider.target = context.coordinator; slider.action = #selector(Coordinator.changed(_:))
        slider.editing = { [weak coordinator = context.coordinator] in coordinator?.parent.onEditingChanged($0) }
        return slider
    }
    func updateNSView(_ slider: IntegerSlider, context: Context) {
        context.coordinator.parent = self
        slider.minValue = range.lowerBound; slider.maxValue = range.upperBound
        slider.isEnabled = enabled; slider.setAccessibilityLabel(label)
        if !slider.tracking { slider.doubleValue = min(range.upperBound,max(range.lowerBound,value.rounded())) }
    }
    final class Coordinator: NSObject {
        var parent: RawParameterSlider
        init(_ parent: RawParameterSlider) { self.parent = parent }
        @objc func changed(_ slider: IntegerSlider) {
            let raw = min(slider.maxValue,max(slider.minValue,slider.doubleValue.rounded()))
            slider.doubleValue = raw; parent.value = raw
        }
    }
}

final class IntegerSlider: NSSlider {
    var tracking = false
    var editing: ((Bool) -> Void)?
    override var acceptsFirstResponder: Bool { true }
    override func mouseDown(with event: NSEvent) {
        guard isEnabled, let window, let cell = cell as? NSSliderCell else { return }
        window.makeFirstResponder(self)
        tracking = true; editing?(true)
        defer { tracking = false; editing?(false) }
        let initial = doubleValue, knob = cell.knobRect(flipped:isFlipped)
        let point = convert(event.locationInWindow,from:nil)
        let offset = knob.contains(point) ? point.x-knob.midX : 0
        doubleValue = minValue; let left = cell.knobRect(flipped:isFlipped).midX
        doubleValue = maxValue; let right = cell.knobRect(flipped:isFlipped).midX
        doubleValue = initial
        func move(_ event: NSEvent) {
            guard isEnabled, right > left else { return }
            let x = convert(event.locationInWindow,from:nil).x-offset
            doubleValue = (minValue + min(1,max(0,(x-left)/(right-left)))*(maxValue-minValue)).rounded()
            _ = sendAction(action,to:target)
        }
        move(event)
        // Track in AppKit's common event mode so MIDI replies and timeouts
        // continue to run while the pointer is held down.
        while let next = window.nextEvent(matching:[.leftMouseDragged,.leftMouseUp],until:.distantFuture,inMode:.eventTracking,dequeue:true) {
            move(next)
            if next.type == .leftMouseUp { break }
        }
    }
    private func step(_ delta: Double) -> Bool {
        guard isEnabled else { return false }
        doubleValue = min(maxValue,max(minValue,doubleValue.rounded()+delta))
        _ = sendAction(action,to:target); return true
    }
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123,125: _ = step(-1)
        case 124,126: _ = step(1)
        default: super.keyDown(with:event)
        }
    }
    override func accessibilityPerformIncrement() -> Bool { step(1) }
    override func accessibilityPerformDecrement() -> Bool { step(-1) }
}
