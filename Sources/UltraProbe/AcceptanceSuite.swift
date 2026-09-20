import Foundation
import UltraCore

/// Explicit, reversible hardware acceptance. Never writes a stored preset slot.
enum AcceptanceSuite {
    static func run(transport: MIDITransport, directory: URL, skipReads: Bool = false, onlyModifiers: Bool = false) throws {
        try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
        var lines: [String] = [], checks: [String] = []
        func record(_ line: String) { print(line); fflush(stdout); lines.append(line) }
        func pass(_ name: String) { checks.append(name); record("PASS " + name) }
        let queue = RequestQueue(sendLong:{ try transport.sendSysEx($0) }) { try transport.send($0) }
        var nativeReply: (([UInt8])->Void)?
        transport.onMessage = { bytes in
            guard UltraProtocol.validEnvelope(bytes), Array(bytes.prefix(5)) == UltraProtocol.modernHeader, bytes[5] != 0x10 else { return }
            if bytes[5] != 2 { record("RX \(bytes.count): " + bytes.prefix(18).map { String(format:"%02X",$0) }.joined(separator:" ")) }; queue.receive(bytes); nativeReply?(bytes)
        }
        defer { try? Data(lines.joined(separator:"\n").utf8).write(to:directory.appendingPathComponent("acceptance.txt")) }
        func transaction(_ bytes: [UInt8], match: @escaping ([UInt8])->Bool, native: Bool = false) throws -> [UInt8] {
            var reply: Result<[UInt8],Error>?
            if native { nativeReply = { if match($0) { reply = .success($0) } }; try transport.sendSysEx(bytes) }
            else { queue.enqueue(.init(bytes:bytes,timeout:4,matches:match) { reply = $0 }) }
            defer { nativeReply = nil }
            let until = Date().addingTimeInterval(7)
            while reply == nil && Date() < until { RunLoop.main.run(until:Date().addingTimeInterval(0.01)) }
            guard let reply else { queue.cancel(); throw MIDIError.message("Hardware acceptance timed out") }
            return try reply.get()
        }
        func patch() throws -> UltraPreset { try UltraPreset(message:transaction(UltraProtocol.patch(),match:{ $0.count == 2060 && $0[5] == 4 && $0[6] == 1 })) }
        func command(_ bytes: [UInt8], function: UInt8, native: Bool = false) throws {
            let result = try transaction(bytes,match:{ UltraProtocol.status($0,for:function) != nil },native:native)
            guard UltraProtocol.status(result,for:function) == 1 else { throw MIDIError.message("Device rejected function \(function)") }
        }
        func parameter(_ effect: Int,_ id: Int,_ raw: Int? = nil) throws -> ParameterValue {
            record("Parameter \(effect):\(id) \(raw.map(String.init) ?? "read")")
            let result = try transaction(UltraProtocol.parameter(effect:effect,parameter:id,value:raw),match:{ UltraProtocol.response($0)?.key == "\(effect):\(id)" })
            guard let value = UltraProtocol.response(result) else { throw MIDIError.message("Invalid parameter response") }; return value
        }
        let baseline = try patch()
        try Data(baseline.message).write(to:directory.appendingPathComponent("before.syx"),options:.atomic)
        record("Baseline: \(baseline.name) • \(baseline.fingerprint). Stored slots are never written.")
        var restored = false
        func restore(_ preset: UltraPreset) throws {
            do { try command(preset.forEditBuffer(),function:4) }
            catch { record("Primary upload failed; using native recovery sender: \(error.localizedDescription)"); queue.cancel(); try command(preset.forEditBuffer(),function:4,native:true) }
            let readback = try patch()
            guard readback.payload == preset.payload else { throw MIDIError.message("Restore verification failed; backup retained at \(directory.path)") }
        }
        defer {
            if !restored {
                do { try restore(baseline); let final = try patch(); try Data(final.message).write(to:directory.appendingPathComponent("after-recovery.syx")); record("RECOVERED original preset byte-for-byte after failed acceptance") }
                catch { record("CRITICAL RESTORE FAILED: \(error.localizedDescription)") }
            }
        }
        // Validate the same native long-message sender and settling interval as the app.
        try command(baseline.forEditBuffer(),function:4)
        let uploaded = try patch()
        try Data(uploaded.message).write(to:directory.appendingPathComponent("after-upload.syx"))
        guard uploaded.payload == baseline.payload else { throw MIDIError.message("Native upload differs") }
        pass("Native edit-buffer upload and all 1024-byte readback")
        let catalog = try Catalog(url:URL(fileURLWithPath:"Resources/UltraCatalog.json"))
        var count = 0
        for effect in baseline.effectParameters.keys.sorted() where !skipReads && ![139,140,141].contains(effect) {
            guard let definition = catalog.effect(effect) else { continue }
            var reads = 0
            for p in definition.parameters where p.id != definition.typeParameterID && p.id < baseline.effectParameters[effect]!.count {
                _ = try parameter(effect,p.id); reads += 1; count += 1
            }
            let after = try patch()
            guard after.payload == baseline.payload else { throw MIDIError.message("Reading \(definition.name) changed preset data") }
            pass("\(catalog.name(effect)): \(reads) safe parameter reads")
        }
        if !skipReads { pass("\(count) current-preset control queries left every byte unchanged") }
        if !onlyModifiers {
        try command(baseline.renamed("Ultra Edit QA").forEditBuffer(),function:4)
        guard try patch().name == "Ultra Edit QA" else { throw MIDIError.message("Rename readback failed") }
        try restore(baseline); pass("Rename and restore")
        if let amp = baseline.effectParameters[106], !amp.isEmpty {
            let alternate = amp[0] == 0 ? 1 : 0
            _ = try parameter(106,0,alternate)
            guard try patch().effectParameters[106]?.first == UInt8(alternate) else { throw MIDIError.message("Amp model readback failed") }
            try restore(baseline); pass("Amp model change and whole-preset restore")
            let p = try parameter(106,1); let target = p.raw == 0 ? 1 : p.raw-1
            _ = try parameter(106,1,target)
            guard try parameter(106,1).raw == target else { throw MIDIError.message("Drive readback failed") }
            _ = try parameter(106,1,p.raw)
            guard try patch().payload == baseline.payload else { throw MIDIError.message("Parameter undo differs") }
            pass("Parameter edit, independent query and undo")
        }
        if let start = (0..<44).first(where:{ baseline.cells[$0].effect == 0 && baseline.cells[$0+4].effect == 0 }) {
            try command(UltraProtocol.place(effect:200,position:start),function:5)
            try command(UltraProtocol.place(effect:200,position:start+4),function:5)
            var read = try patch()
            guard read.cells[start].effect >= 200, read.cells[start+4].effect >= 200 else { throw MIDIError.message("Shunt placement failed") }
            try command(UltraProtocol.connect(source:start,destination:start+4,enabled:true),function:6)
            read = try patch()
            guard read.cells[start+4].inputMask & (1 << (start%4)) != 0 else { throw MIDIError.message("Routing connection failed") }
            try command(UltraProtocol.connect(source:start,destination:start+4,enabled:false),function:6)
            guard try patch().cells[start+4].inputMask & (1 << (start%4)) == 0 else { throw MIDIError.message("Routing disconnect failed") }
            try command(UltraProtocol.place(effect:0,position:start),function:5)
            guard try patch().cells[start].effect == 0 else { throw MIDIError.message("Remove block failed") }
            try restore(baseline); pass("Shunt placement, connect, disconnect, removal and restore")
        }
        }
        if let p = catalog.effect(106)?.parameters.first(where:{$0.id == 1}), p.modifierID > 0 {
            func modifier(_ field: Int,_ value: Int? = nil) throws -> Int {
                let reply = try transaction(UltraProtocol.modifier(effect:106,parameter:p.modifierID,modifier:field,value:value),match:{ $0.count >= 16 && $0[5] == 7 && UltraProtocol.byte($0[6],$0[7]) == 106 && UltraProtocol.byte($0[8],$0[9]) == p.modifierID && UltraProtocol.byte($0[10],$0[11]) == field })
                return UltraProtocol.byte(reply[12],reply[13])
            }
            var fields: [Int:Int] = [:]
            for field in [0,1,2,3,4,5,10,11,12] { fields[field] = try modifier(field) }
            guard try patch().payload == baseline.payload else { throw MIDIError.message("Modifier reads mutated preset") }
            if fields[0] == 0 { _ = try modifier(0,1); guard try modifier(0) == 1 else { throw MIDIError.message("Modifier source assignment not confirmed") } }
            let original = try modifier(5), target = original == 0 ? 1 : original-1
            _ = try modifier(5,target)
            guard try modifier(5) == target else { throw MIDIError.message("Modifier write not confirmed") }
            _ = try modifier(5,original)
            try restore(baseline); pass("Nine modifier reads, damping edit/readback and restore")
        }
        try restore(baseline)
        let final = try patch()
        try Data(final.message).write(to:directory.appendingPathComponent("after.syx"),options:.atomic)
        restored = true
        pass("Final preset equals original, all 1024 bytes")
        let summary: [String:Any] = ["date":ISO8601DateFormatter().string(from:Date()),"checks":checks,"preset":baseline.name,"beforeSHA256":baseline.fingerprint,"afterSHA256":final.fingerprint,"persistentSlotWrites":0]
        try JSONSerialization.data(withJSONObject:summary,options:[.prettyPrinted,.sortedKeys]).write(to:directory.appendingPathComponent("acceptance.json"))
    }
}
