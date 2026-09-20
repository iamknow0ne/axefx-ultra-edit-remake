import Foundation
import CoreMIDI

public struct MIDIEndpoint: Identifiable, Equatable {
    public let id: MIDIEndpointRef
    public let name: String
    public let uniqueID: Int32
}

/// A MIDI 1.0 byte stream can span packets and contain interleaved real-time bytes.
public struct SysExFramer {
    private var buffer: [UInt8] = []
    public init() {}
    public mutating func feed(_ bytes: [UInt8]) -> [[UInt8]] {
        var messages: [[UInt8]] = []
        for byte in bytes {
            if byte >= 0xF8 { continue }
            if byte == 0xF0 { buffer = [byte] }
            else if byte == 0xF7 {
                if !buffer.isEmpty { buffer.append(byte); messages.append(buffer); buffer.removeAll(keepingCapacity: true) }
            } else if byte >= 0x80 { buffer.removeAll(keepingCapacity: true) }
            else if !buffer.isEmpty {
                buffer.append(byte)
                if buffer.count > 524_288 { buffer.removeAll(keepingCapacity: true) }
            }
        }
        return messages
    }
}

public final class MIDITransport {
    private var client: MIDIClientRef = 0
    private var input: MIDIPortRef = 0
    private var output: MIDIPortRef = 0
    private var source: MIDIEndpointRef = 0
    private var destination: MIDIEndpointRef = 0
    private var framer = SysExFramer()
    private let receiveQueue = DispatchQueue(label: "tech.hostin.ultra.receive")
    public var onMessage: (([UInt8]) -> Void)?
    public var onBytes: (([UInt8]) -> Void)?
    public var onChange: (() -> Void)?
    public init() throws {
        try check(MIDIClientCreateWithBlock("Ultra Edit" as CFString, &client) { [weak self] _ in
            DispatchQueue.main.async { self?.onChange?() }
        })
        try check(MIDIInputPortCreateWithBlock(client, "Ultra In" as CFString, &input) { [weak self] list, _ in
            var packetPointer = UnsafeRawPointer(list).advanced(by: MemoryLayout<MIDIPacketList>.offset(of: \.packet)!).assumingMemoryBound(to: MIDIPacket.self)
            for _ in 0..<list.pointee.numPackets {
                let dataPointer = UnsafeRawPointer(packetPointer).advanced(by: MemoryLayout<MIDIPacket>.offset(of: \.data)!).assumingMemoryBound(to: UInt8.self)
                let bytes = Array(UnsafeBufferPointer(start: dataPointer, count: Int(packetPointer.pointee.length)))
                self?.receiveQueue.async { [weak self] in
                    guard let self else { return }
                    if let callback = self.onBytes { DispatchQueue.main.async { callback(bytes) } }
                    for message in self.framer.feed(bytes) {
                        DispatchQueue.main.async { self.onMessage?(message) }
                    }
                }
                packetPointer = UnsafePointer(MIDIPacketNext(packetPointer))
            }
        })
        try check(MIDIOutputPortCreate(client, "Ultra Out" as CFString, &output))
    }
    public static func endpoints(input: Bool) -> [MIDIEndpoint] {
        let count = input ? MIDIGetNumberOfSources() : MIDIGetNumberOfDestinations()
        return (0..<count).map { index in
            let endpoint = input ? MIDIGetSource(index) : MIDIGetDestination(index)
            var name: Unmanaged<CFString>?
            var uniqueID: Int32 = 0
            MIDIObjectGetStringProperty(endpoint, kMIDIPropertyDisplayName, &name)
            MIDIObjectGetIntegerProperty(endpoint, kMIDIPropertyUniqueID, &uniqueID)
            return MIDIEndpoint(id: endpoint, name: name?.takeRetainedValue() as String? ?? "MIDI port", uniqueID: uniqueID)
        }
    }
    public func connect(source: MIDIEndpointRef, destination: MIDIEndpointRef) throws {
        disconnect()
        try check(MIDIPortConnectSource(input, source, nil))
        self.source = source; self.destination = destination
    }
    public func disconnect() {
        if source != 0 { MIDIPortDisconnectSource(input, source) }
        source = 0; destination = 0
        receiveQueue.sync { framer = SysExFramer() }
    }
    public func sendSysEx(_ bytes: [UInt8]) throws {
        guard destination != 0, bytes.first == 0xF0, bytes.last == 0xF7 else { throw MIDIError.message("Invalid SysEx destination or message.") }
        try SysExFlight(destination: destination, bytes: bytes).start()
    }
    public func send(_ bytes: [UInt8]) throws {
        guard destination != 0 else { throw MIDIError.message("Choose and connect a MIDI output first.") }
        guard !bytes.isEmpty, bytes.count <= 256 else { throw MIDIError.message("Message exceeds the short-message transport limit.") }
        var list = MIDIPacketList()
        let result = withUnsafeMutablePointer(to: &list) { ptr -> OSStatus in
            let packet = MIDIPacketListInit(ptr)
            return bytes.withUnsafeBufferPointer { data in
                _ = MIDIPacketListAdd(ptr, MemoryLayout<MIDIPacketList>.size, packet, 0, data.count, data.baseAddress!)
                return MIDISend(output, destination, ptr)
            }
        }
        try check(result)
    }
    private func check(_ status: OSStatus) throws { if status != noErr { throw MIDIError.message("CoreMIDI error \(status)") } }
    deinit { if client != 0 { MIDIClientDispose(client) } }
}
public enum MIDIError: LocalizedError {
    case message(String)
    public var errorDescription: String? { if case .message(let value) = self { return value }; return nil }
}

/// CoreMIDI's asynchronous SysEx sender requires storage to outlive the call.
private final class SysExFlight {
    let storage: UnsafeMutablePointer<UInt8>
    let request: UnsafeMutablePointer<MIDISysexSendRequest>
    init(destination: MIDIEndpointRef, bytes: [UInt8]) {
        storage = .allocate(capacity: bytes.count); storage.initialize(from: bytes,count:bytes.count)
        request = .allocate(capacity:1)
        request.initialize(to:MIDISysexSendRequest(destination:destination,data:UnsafePointer(storage),bytesToSend:UInt32(bytes.count),complete:false,reserved:(0,0,0),completionProc:{ ptr in
            guard let context = ptr.pointee.completionRefCon else { return }
            _ = Unmanaged<SysExFlight>.fromOpaque(context).takeRetainedValue()
        },completionRefCon:nil))
    }
    func start() throws {
        request.pointee.completionRefCon = Unmanaged.passRetained(self).toOpaque()
        let status = MIDISendSysex(request)
        if status != noErr {
            _ = Unmanaged<SysExFlight>.fromOpaque(request.pointee.completionRefCon!).takeRetainedValue()
            throw MIDIError.message("CoreMIDI SysEx send error \(status)")
        }
    }
    deinit { storage.deallocate(); request.deinitialize(count:1); request.deallocate() }
}
