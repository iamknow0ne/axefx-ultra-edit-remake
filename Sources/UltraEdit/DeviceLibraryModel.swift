import Foundation
import UltraCore

extension EditorModel {
    func stopDeviceRead() { deviceReadToken = UUID(); readingDevice = false }
    func readDeviceSlots(_ slots: [Int] = Array(0..<384)) {
        guard connected, !connecting, !gridWorking, !readingDevice, busy == 0, liveKey == nil else { return }
        let slots = slots.filter { (0..<384).contains($0) }
        guard !slots.isEmpty else { return }
        let token = UUID(); deviceReadToken = token; readingDevice = true; deviceReadCount = 0
        func next(_ index: Int) {
            guard self.connected, self.deviceReadToken == token else { return }
            guard index < slots.count else { self.readingDevice = false; self.status = "Read \(slots.count) stored preset(s) • current sound unchanged"; return }
            let slot = slots[index]
            self.status = "Reading Ultra slot \(slot) • \(index+1) of \(slots.count)"
            self.request(try! UltraProtocol.storedPreset(slot,header:self.header),timeout:4,priority:.background,match:{ bytes in
                (try? UltraPreset.storedReply(bytes,requestedSlot:slot)) != nil
            }) { [weak self] result in
                guard let self, self.deviceReadToken == token else { return }
                do {
                    let preset = try UltraPreset.storedReply(result.get(),requestedSlot:slot)
                    self.devicePresets[slot] = SavedPreset(preset:preset,title:preset.name.isEmpty ? "Unnamed preset" : nil,source:"Ultra slot \(slot) · bank \(["A","B","C"][slot/128])")
                    self.deviceReadCount = index+1
                    // Yield between reads, so Stop and interactive parameter work can run.
                    DispatchQueue.main.async { next(index+1) }
                } catch { self.readingDevice = false; self.fail(error) }
            }
        }
        next(0)
    }
    func previewDeviceSlot(_ slot: Int) {
        guard !draftMode, !readingDevice, busy == 0 else { return }
        if let entry = devicePresets[slot] { inspect(entry) }
        else { readDeviceSlots([slot]) }
    }
    func copyDeviceSlot(_ slot: Int) {
        guard let entry = devicePresets[slot] else { return }
        // Slots are not deduplicated: identical presets at different addresses
        // are distinct entries in the device browser.
        library.append(SavedPreset(preset:entry.preset!,source:entry.source))
        do { try saveArchive(library,name:"library"); status = "Slot \(slot) copied to the Mac library" } catch { fail(error) }
    }
}
