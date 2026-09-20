import Foundation

public struct GridLink: Hashable, Identifiable {
    public let source: Int
    public let destination: Int
    public var id: String { "\(source):\(destination)" }
    public init(source: Int, destination: Int) { self.source = source; self.destination = destination }
}
public enum GridEdit {
    case remove(Int)
    case move(source: Int, destination: Int, detach: Bool = false)
    case link(GridLink, enabled: Bool)
    case reroute(GridLink, to: GridLink)
}
public extension UltraPreset {
    var gridLinks: [GridLink] {
        cells.filter { $0.column > 0 }.flatMap { cell in
            (0..<4).filter { cell.inputMask & (1 << $0) != 0 }.map { GridLink(source:(cell.column-1)*4+$0,destination:cell.id) }
        }
    }
    /// Only the 96 routing bytes change. Effect records, modifiers and opaque
    /// data retain their exact original bytes, including when swapping effects.
    func editingGrid(_ edit: GridEdit) throws -> UltraPreset {
        var data = payload
        func valid(_ position: Int) throws {
            guard (0..<48).contains(position) else { throw MIDIError.message("Choose a cell inside the 4 × 12 grid.") }
        }
        func set(_ link: GridLink, _ enabled: Bool) throws {
            try valid(link.source); try valid(link.destination)
            guard link.destination/4 == link.source/4+1 else { throw MIDIError.message("Cables connect to the next column. Use shunts to span more columns.") }
            if enabled {
                guard data[34+link.source*2] != 0, data[34+link.destination*2] != 0 else { throw MIDIError.message("Connect a block or shunt at each end of the cable.") }
            }
            let offset = 35+link.destination*2, bit = UInt8(1 << (link.source%4))
            if enabled { data[offset] |= bit } else { data[offset] &= ~bit }
        }
        switch edit {
        case let .remove(position):
            try valid(position)
            for link in gridLinks where link.source == position || link.destination == position { try set(link,false) }
            data[34+position*2] = 0; data[35+position*2] &= 0xF0
        case let .link(link, enabled): try set(link,enabled)
        case let .reroute(old, new):
            guard gridLinks.contains(old) else { throw MIDIError.message("That cable has changed. Try again.") }
            try set(old,false); try set(new,true)
        case let .move(source,destination,detach):
            try valid(source); try valid(destination)
            guard source != destination else { return self }
            guard cells[source].effect != 0 else { throw MIDIError.message("Choose a block to move.") }
            if cells[destination].effect != 0 {
                // Swapping processing order retains the patch-bay wiring.
                data.swapAt(34+source*2,34+destination*2)
            } else {
                let affected = gridLinks.filter { $0.source == source || $0.destination == source }
                let mapped = affected.map { GridLink(source:$0.source == source ? destination : $0.source,destination:$0.destination == source ? destination : $0.destination) }
                let detached = mapped.filter { $0.destination/4 != $0.source/4+1 }
                guard detach || detached.isEmpty else { throw MIDIError.message("Option-drag to move and detach \(detached.count) cable(s), or stay in this column.") }
                // Clear stale routes into the empty target and from its old row.
                for link in gridLinks where link.source == source || link.destination == source || link.source == destination || link.destination == destination { try set(link,false) }
                data[34+destination*2] = data[34+source*2]; data[34+source*2] = 0
                // The upper nibble is opaque; never rebuild entire input bytes.
                data[35+destination*2] = (data[35+destination*2] & 0xF0) | (source/4 == 0 && destination/4 == 0 ? payload[35+source*2] & 15 : 0)
                data[35+source*2] &= 0xF0
                for link in mapped where link.destination/4 == link.source/4+1 { try set(link,true) }
            }
        }
        return try replacingPayload(data)
    }
}
