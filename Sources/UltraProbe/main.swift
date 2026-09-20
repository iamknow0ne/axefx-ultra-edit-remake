import Foundation
import CoreMIDI
import UltraCore
let args = CommandLine.arguments
func option(_ name: String) -> String? { guard let i = args.firstIndex(of:name), args.indices.contains(i+1) else { return nil }; return args[i+1] }
if args.contains("--help") {
    print("""
    ultra-probe [--ports] [--input NAME] [--output NAME] [--legacy]
                [--capture-directory PATH] [--simulate]
    Default operation only queries firmware, preset name, edit buffer and Amp 1 Drive.
    --simulate exposes a virtual Ultra for app and transport testing; no hardware access.
    --verify-suite runs reversible edit-buffer acceptance tests with backup/restore; no stored slots.
    --verify-banks reads all 384 presets and verifies bank exports; no writes.
    --verify-performance changes/restores preset-global fields and bypass flags in the edit buffer.
    --verify-store SLOT temporarily OVERWRITES the specified stored slot, backs it up and restores it.
      Use only an explicitly authorized expendable destination; interruption can require manual recovery.
    Close other editors before hardware probes. No firmware transfer is implemented.
    """); exit(0)
}
if args.contains("--simulate") {
    try Simulator.run(); exit(0)
}
let transport = try MIDITransport()
let ins = MIDITransport.endpoints(input:true), outs = MIDITransport.endpoints(input:false)
for port in ins { print("INPUT \(port.id) \(port.name)") }
for port in outs { print("OUTPUT \(port.id) \(port.name)") }
if args.contains("--ports") { exit(0) }
func select(_ ports: [MIDIEndpoint], name: String?) -> MIDIEndpoint? {
    if let name { return ports.first { $0.name == name } }
    return ports.count == 1 ? ports.first : ports.first { $0.name.contains("Clarett") }
}
guard let source = select(ins,name:option("--input")),let destination = select(outs,name:option("--output")) else { print("Select a MIDI input and output by name with --input and --output."); exit(1) }
try transport.connect(source:source.id,destination:destination.id)
RunLoop.main.run(until:Date().addingTimeInterval(0.3))
let outputURL = URL(fileURLWithPath:option("--capture-directory") ?? "evidence")
try FileManager.default.createDirectory(at:outputURL,withIntermediateDirectories:true)
if args.contains("--verify-banks") {
    do { try BankVerification.run(transport:transport,directory:outputURL); exit(0) }
    catch { fputs("Bank verification stopped: \(error.localizedDescription)\n",stderr); exit(1) }
}
if args.contains("--verify-performance") {
    do { try PerformanceVerification.run(transport:transport,directory:outputURL); exit(0) }
    catch { fputs("Performance verification stopped: \(error.localizedDescription)\n",stderr); exit(1) }
}
if let value = option("--verify-store"), let slot = Int(value) {
    do { try StoreVerification.run(transport:transport,slot:slot,directory:outputURL); exit(0) }
    catch { fputs("Store verification stopped: \(error.localizedDescription)\n",stderr); exit(1) }
}
if args.contains("--verify-grid") || args.contains("--verify-stored") {
    do { try GridVerification.run(transport:transport,directory:outputURL,storedOnly:args.contains("--verify-stored")); exit(0) }
    catch { fputs("Verification stopped: \(error.localizedDescription)\n",stderr); exit(1) }
}
if args.contains("--measure-latency") {
    try LatencyVerification.run(transport:transport,directory:outputURL); exit(0)
}
if args.contains("--verify-suite") {
    do { try AcceptanceSuite.run(transport:transport,directory:outputURL,skipReads:args.contains("--skip-reads"),onlyModifiers:args.contains("--only-modifiers")); exit(0) }
    catch { fputs("Acceptance stopped: \(error.localizedDescription)\n",stderr); exit(1) }
}
if let file = option("--restore-buffer") {
    try BufferRecovery.run(transport:transport,url:URL(fileURLWithPath:file),directory:outputURL,queryParameter:option("--diagnose-query").flatMap(Int.init))
    exit(0)
}
if args.contains("--verify-edit") || args.contains("--verify-reads") {
    try HardwareVerification.run(transport:transport,header:UltraProtocol.header(legacy:args.contains("--legacy")),directory:outputURL,readControls:args.contains("--verify-reads"))
    exit(0)
}
var count = 0
var rawCount = 0
var tempoCount = 0
var trace: [String] = []
func record(_ line: String) { print(line); trace.append(line); fflush(stdout) }
transport.onBytes = { bytes in
    rawCount += bytes.count
    if rawCount < 1024 { record("RAW " + bytes.prefix(96).map { String(format:"%02X",$0) }.joined(separator:" ")) }
}
transport.onMessage = { bytes in
    if bytes.count > 6, bytes[5] == 0x10 { tempoCount += 1; if tempoCount <= 3 { record("TEMPO " + bytes.map { String(format:"%02X",$0) }.joined(separator:" ")) }; return }
    guard bytes.count > 6 else { return }
    count += 1
    record("RX \(bytes.count): " + bytes.prefix(90).map { String(format:"%02X",$0) }.joined(separator:" "))
    try? Data(bytes).write(to:outputURL.appendingPathComponent("probe-\(count)-function-\(bytes[5]).syx"))
}
let header = UltraProtocol.header(legacy:args.contains("--legacy"))
let messages = [UltraProtocol.firmware(header:header),UltraProtocol.name(header:header),UltraProtocol.patch(header:header),try UltraProtocol.parameter(effect:106,parameter:1,header:header)]
for (index,message) in messages.enumerated() {
    DispatchQueue.main.asyncAfter(deadline:.now()+Double(index)*1.2) {
        record("TX " + message.map { String(format:"%02X",$0) }.joined(separator:" "))
        do { if args.contains("--native-sysex") { try transport.sendSysEx(message) } else { try transport.send(message) } } catch { record(error.localizedDescription) }
    }
}
RunLoop.main.run(until:Date().addingTimeInterval(9))
record("Received \(count) non-tempo messages; \(tempoCount) tempo messages; \(rawCount) raw MIDI bytes")
try Data(trace.joined(separator:"\n").utf8).write(to:outputURL.appendingPathComponent("probe-\(args.contains("--legacy") ? "legacy" : "modern")-log.txt"))
exit(count == 0 ? 2 : 0)
