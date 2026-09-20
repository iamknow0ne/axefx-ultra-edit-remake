import Foundation
import UltraCore

struct DeviceCacheProfile: Codable {
    let key: String
    let label: String
}

extension EditorModel {
    var deviceCacheRoot: URL { archiveURL("library").deletingLastPathComponent().appendingPathComponent("Device Cache") }
    var currentDeviceCacheProfile: DeviceCacheProfile {
        let input = inputs.first { $0.id == inputID }, output = outputs.first { $0.id == outputID }
        let identity = "\(input?.uniqueID ?? Int32(bitPattern:inputID))|\(output?.uniqueID ?? Int32(bitPattern:outputID))|\(channel)|\(header)"
        let key = identity.utf8.map { String(format:"%02x",$0) }.joined()
        return DeviceCacheProfile(key:key,label:"\(input?.name ?? "MIDI") → \(output?.name ?? "MIDI") · channel \(channel)")
    }
    func deviceCacheURL(slot: Int, profile: DeviceCacheProfile) -> URL {
        deviceCacheRoot.appendingPathComponent(profile.key).appendingPathComponent(String(format:"%03d.json",slot))
    }
    func restoreLastDeviceCache() {
        let url = deviceCacheRoot.appendingPathComponent("last-profile.json")
        guard FileManager.default.fileExists(atPath:url.path) else { return }
        do { try loadDeviceCache(WorkspaceFile.load(DeviceCacheProfile.self,from:url)) }
        catch { deviceCacheWarning = "Saved device cache could not be read. Refresh from the Ultra to rebuild it." }
    }
    func selectDeviceCache() {
        do { try loadDeviceCache(currentDeviceCacheProfile) }
        catch { deviceCacheWarning = "Saved device cache could not be read. Refresh from the Ultra to rebuild it." }
    }
    func loadDeviceCache(_ profile: DeviceCacheProfile) throws {
        // Profile keys are encoded endpoint IDs/channel/protocol, never file paths.
        guard !profile.key.isEmpty, profile.key.count <= 512, profile.key.allSatisfy({ $0.isHexDigit }) else { throw MIDIError.message("Invalid device cache profile.") }
        deviceCacheProfile = profile; devicePresets = [:]; deviceCacheDate = nil; deviceCacheWarning = nil; selectedLibrarySlot = nil
        var invalid = 0
        for slot in 0..<384 {
            let url = deviceCacheURL(slot:slot,profile:profile)
            guard FileManager.default.fileExists(atPath:url.path) else { continue }
            do {
                let entry = try WorkspaceFile.load(SavedPreset.self,from:url)
                guard entry.preset?.storedSlot == slot else { throw MIDIError.message("Invalid cached slot") }
                devicePresets[slot] = entry
                deviceCacheDate = max(deviceCacheDate ?? .distantPast,entry.created)
            } catch { invalid += 1 }
        }
        if invalid > 0 { deviceCacheWarning = "\(invalid) unreadable cached slot(s). Refresh from the Ultra to replace them." }
    }
    func cacheDevicePreset(_ preset: UltraPreset, slot: Int) {
        guard (0..<384).contains(slot), preset.storedSlot == slot else { return }
        let profile = currentDeviceCacheProfile
        if deviceCacheProfile?.key != profile.key { selectDeviceCache() }
        let entry = SavedPreset(preset:preset,title:preset.name.isEmpty ? "Empty preset" : nil,source:"Ultra slot \(slot) · bank \(["A","B","C"][slot/128])")
        devicePresets[slot] = entry
        do {
            // One atomic file per slot: interrupted scans keep completed reads,
            // without re-encoding the whole 384-preset library on every reply.
            try WorkspaceFile.save(entry,to:deviceCacheURL(slot:slot,profile:profile))
            try WorkspaceFile.save(profile,to:deviceCacheRoot.appendingPathComponent("last-profile.json"))
            deviceCacheDate = entry.created
        } catch { deviceCacheWarning = "Preset read succeeded, but the Mac cache could not be saved. Check free space and folder permissions." }
    }

    func stopDeviceRead() { deviceReadToken = UUID(); readingDevice = false }
    func readDeviceSlots(_ slots: [Int] = Array(0..<384), completion: (() -> Void)? = nil) {
        guard !librarySwitching, connected, !connecting, !gridWorking, !readingDevice, busy == 0, liveKey == nil else { return }
        let slots = slots.filter { (0..<384).contains($0) }
        guard !slots.isEmpty else { return }
        let token = UUID(); deviceReadToken = token; readingDevice = true; deviceReadCount = 0
        func next(_ index: Int) {
            guard self.connected, self.deviceReadToken == token else { return }
            guard index < slots.count else { self.readingDevice = false; self.status = "Read \(slots.count) stored preset(s) • current sound unchanged"; completion?(); return }
            let slot = slots[index]
            self.status = "Reading Ultra slot \(slot) • \(index+1) of \(slots.count)"
            self.request(try! UltraProtocol.storedPreset(slot,header:self.header),timeout:4,priority:.background,match:{ bytes in
                (try? UltraPreset.storedReply(bytes,requestedSlot:slot)) != nil
            }) { [weak self] result in
                guard let self, self.deviceReadToken == token else { return }
                do {
                    let preset = try UltraPreset.storedReply(result.get(),requestedSlot:slot)
                    self.cacheDevicePreset(preset,slot:slot)
                    self.deviceReadCount = index+1
                    // Yield between reads, so Stop and interactive parameter work can run.
                    DispatchQueue.main.async { next(index+1) }
                } catch { self.readingDevice = false; self.fail(error) }
            }
        }
        next(0)
    }
    func previewDeviceSlot(_ slot: Int) {
        guard !librarySwitching, !draftMode, !readingDevice, busy == 0 else { return }
        selectedLibrarySlot = slot
        if let entry = devicePresets[slot] { inspect(entry) }
        else { readDeviceSlots([slot]) { [weak self] in
            guard let self, let entry = self.devicePresets[slot] else { return }; self.inspect(entry)
        } }
    }
    func copyDeviceSlot(_ slot: Int) {
        guard let entry = devicePresets[slot] else { return }
        // Slots are not deduplicated: identical presets at different addresses
        // are distinct entries in the device browser.
        library.append(SavedPreset(preset:entry.preset!,source:entry.source))
        do { try saveArchive(library,name:"library"); status = "Slot \(slot) copied to the Mac library" } catch { fail(error) }
    }
}
