import Foundation
import CoreMIDI
import UltraCore

final class Simulator {
    var client: MIDIClientRef = 0
    var source: MIDIEndpointRef = 0
    var destination: MIDIEndpointRef = 0
    var framer = SysExFramer()
    var catalog: Catalog
    var preset: UltraPreset
    var values: [String:Int] = [:]
    var received = 0
    init() throws {
        catalog = try Catalog(url:URL(fileURLWithPath:"Resources/UltraCatalog.json"))
        let url = URL(fileURLWithPath:"Tests/Fixtures/synthetic-preset.syx")
        preset = try UltraPreset.readFile(Data(contentsOf:url))[0]
        guard MIDIClientCreate("Ultra Edit Simulator" as CFString,nil,nil,&client) == noErr else { throw MIDIError.message("Cannot create simulator MIDI client") }
        MIDISourceCreate(client,"Ultra Edit Simulator" as CFString,&source)
        MIDIDestinationCreateWithBlock(client,"Ultra Edit Simulator" as CFString,&destination) { [weak self] list,_ in
            var pointer = UnsafeRawPointer(list).advanced(by:MemoryLayout<MIDIPacketList>.offset(of:\.packet)!).assumingMemoryBound(to:MIDIPacket.self)
            for _ in 0..<list.pointee.numPackets {
                let data = UnsafeRawPointer(pointer).advanced(by:MemoryLayout<MIDIPacket>.offset(of:\.data)!).assumingMemoryBound(to:UInt8.self)
                let bytes = Array(UnsafeBufferPointer(start:data,count:Int(pointer.pointee.length)))
                DispatchQueue.main.async { [weak self] in guard let self else { return }; for message in self.framer.feed(bytes) { self.handle(message) } }
                pointer = UnsafePointer(MIDIPacketNext(pointer))
            }
        }
        print("SIMULATOR ready — virtual input/output: Ultra Edit Simulator. No physical MIDI ports are used."); fflush(stdout)
    }
    func handle(_ bytes: [UInt8]) {
        guard UltraProtocol.validEnvelope(bytes) else { return }
        received += 1
        let h = Array(bytes.prefix(5))
        switch bytes[5] {
        case 8: reply(h + [8,11,0,0xF7])
        case 15: reply(h + [15] + Array(preset.name.utf8) + [0,0xF7])
        case 3:
            if bytes.count == 10 { reply(bytes[6] == 1 ? preset.forEditBuffer(header:h) : (try! preset.forStorage(slot:UltraProtocol.byte(bytes[7],bytes[8]),header:h))) }
        case 2:
            guard bytes.count == 14 else { return }
            let effect = UltraProtocol.byte(bytes[6],bytes[7]), id = UltraProtocol.byte(bytes[8],bytes[9])
            guard let parameter = catalog.effect(effect)?.parameters.first(where:{ $0.id == id }) else { return }
            guard let record = preset.effectParameters[effect], record.indices.contains(id) else { return }
            if bytes[12] == 1 {
                var payload = preset.payload, offset = 130
                while offset+2 < payload.count {
                    let count = Int(payload[offset+1])
                    if Int(payload[offset]) == effect { payload[offset+2+id] = UInt8(min(parameter.rawMaximum,UltraProtocol.byte(bytes[10],bytes[11]))); break }
                    if count == 0 { break }; offset += 2+count
                }
                update(payload)
            }
            let raw = Int(preset.effectParameters[effect]![id])
            var response = h + [UInt8(2)]
            response += Array(bytes[6..<10]); response += UltraProtocol.nibbles(raw); response += Array(parameter.estimate(raw).utf8); response += [0,0xF7]
            reply(response)
        case 4:
            do { preset = try UltraPreset(message:bytes); reply(h + [4,1,0xF7]) } catch { reply(h + [4,0,0xF7]) }
        case 9:
            guard bytes.count == 30 else { return }
            var payload = preset.payload; payload.replaceSubrange(2..<22,with:bytes[6..<26]); update(payload)
            reply(h + [9,1,0xF7])
        case 5:
            guard bytes.count == 10,bytes[8] < 48 else { return }
            var payload = preset.payload; payload[34+Int(bytes[8])*2] = UInt8(UltraProtocol.byte(bytes[6],bytes[7])); update(payload)
            reply(h + [5,1,0xF7])
        case 6:
            guard bytes.count == 10,bytes[6] < 48,bytes[7] < 48 else { return }
            var payload = preset.payload; let at = 35+Int(bytes[7])*2; let mask = UInt8(1 << (bytes[6] % 4))
            if bytes[8] == 1 { payload[at] |= mask } else { payload[at] &= ~mask }; update(payload); reply(h + [6,1,0xF7])
        case 7:
            guard bytes.count == 16 else { return }
            let key = "mod:" + bytes[6..<12].map(String.init).joined(separator:":")
            if bytes[14] == 1 { values[key] = UltraProtocol.byte(bytes[12],bytes[13]) }
            let value = values[key] ?? 0
            var response = h + [UInt8(7)]; response += Array(bytes[6..<12]); response += UltraProtocol.nibbles(value); response += Array("Value \(value)".utf8); response += [0,0xF7]; reply(response)
        default: break
        }
    }
    func update(_ payload: [UInt8]) {
        var message = UltraProtocol.modernHeader + [4,1,0,0]
        message += payload.flatMap { UltraProtocol.nibbles(Int($0)) }; message += UltraProtocol.nibbles(Int(payload.reduce(0,^))); message += [0xF7]
        preset = try! UltraPreset(message:message)
    }
    func reply(_ bytes: [UInt8]) {
        // Fragmented delivery exercises the production stream reassembler.
        for (index,start) in stride(from:0,to:bytes.count,by:96).enumerated() {
            let fragment = Array(bytes[start..<min(start+96,bytes.count)])
            DispatchQueue.main.asyncAfter(deadline:.now()+0.02+Double(index)*0.035) { [weak self] in
                guard let self else { return }
                var list = MIDIPacketList()
                withUnsafeMutablePointer(to:&list) { ptr in
                    let packet = MIDIPacketListInit(ptr)
                    fragment.withUnsafeBufferPointer { data in _ = MIDIPacketListAdd(ptr,MemoryLayout<MIDIPacketList>.size,packet,0,data.count,data.baseAddress!) }
                    MIDIReceived(self.source,ptr)
                }
            }
        }
    }
    static func run() throws { let simulator = try Simulator(); withExtendedLifetime(simulator) { RunLoop.main.run() } }
    deinit { MIDIClientDispose(client) }
}
