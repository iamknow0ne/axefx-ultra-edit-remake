import SwiftUI
import AppKit
import UltraCore

struct GridView: View, Equatable {
    let model: EditorModel
    private let cells: [GridCell]
    private let selectedCell: Int?
    private let connections: Bool
    private let editable: Bool
    private let undoCount: Int
    private let redoCount: Int
    @State private var moving: Int?
    @State private var pointer = CGPoint.zero
    @State private var target: Int?
    @State private var detach = false
    @State private var wiring: Int?
    @State private var fromInput = false
    @State private var replacing: GridLink?
    @State private var selectedLink: GridLink?
    @State private var hint = "Drag blocks to move · Arrows select · Option-arrows move · Delete removes"
    @FocusState private var focused: Bool
    init(model: EditorModel) {
        self.model = model; cells = model.cells; selectedCell = model.selectedCell
        connections = model.showConnections; editable = model.canEditGrid
        undoCount = model.draftMode ? model.draftUndo.count : model.gridUndo.count; redoCount = model.draftMode ? model.draftRedo.count : model.gridRedo.count
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.model === rhs.model && lhs.cells == rhs.cells && lhs.selectedCell == rhs.selectedCell && lhs.connections == rhs.connections && lhs.editable == rhs.editable && lhs.undoCount == rhs.undoCount && lhs.redoCount == rhs.redoCount
    }
    private var links: [GridLink] { model.currentPreset?.gridLinks ?? [] }
    var body: some View {
        VStack(alignment:.leading,spacing:8) {
            HStack(spacing:12) {
                Text("SIGNAL PATH").font(.system(size:10,weight:.semibold)).tracking(1.5)
                Text("IN → OUT").font(.system(size:10,design:.monospaced)).foregroundStyle(StudioTheme.muted)
                Spacer()
                if let link = selectedLink {
                    Button("Disconnect cable") { remove(link) }.disabled(!editable)
                }
                Button("Copy effect",action:model.copyEffectToClipboard).disabled(model.currentPreset == nil || model.busy > 0 || !model.selectedControlsWritable || model.isPresetGlobal)
                Button("Paste effect",action:model.pasteEffectFromClipboard).disabled(!editable || model.isPresetGlobal)
                Button { if model.draftMode { model.undoDraft() } else { model.undoGrid() } } label: { Image(systemName:"arrow.uturn.backward") }.accessibilityLabel("Undo routing").help("Undo routing").disabled(!editable || undoCount == 0)
                Button { if model.draftMode { model.redoDraft() } else { model.redoGrid() } } label: { Image(systemName:"arrow.uturn.forward") }.accessibilityLabel("Redo routing").help("Redo routing").disabled(!editable || redoCount == 0)
                Toggle("Cables",isOn:Binding(get:{model.showConnections},set:{model.showConnections = $0})).toggleStyle(.checkbox)
            }.font(.caption).controlSize(.small)
            GeometryReader { geometry in
                let step = geometry.size.width/12
                ZStack(alignment:.topLeading) {
                    ForEach(0..<48,id:\.self) { position in
                        RoundedRectangle(cornerRadius:4)
                            .strokeBorder(target == position ? (validTarget ? StudioTheme.accent : .red) : Color.white.opacity(moving == nil ? 0.04 : 0.13),style:StrokeStyle(lineWidth:target == position ? 2 : 1,dash:target == position ? [] : [2,4]))
                            .frame(width:step-18,height:52).position(center(position,step:step))
                            .allowsHitTesting(false)
                    }
                    if connections {
                        ForEach(links) { link in
                            let path = cable(port(link.source,input:false,step:step),port(link.destination,input:true,step:step))
                            path.stroke(selectedLink == link ? StudioTheme.text : StudioTheme.accent.opacity(0.7),lineWidth:selectedLink == link ? 3 : 1.8)
                                .contentShape(path.strokedPath(StrokeStyle(lineWidth:14)))
                                .onTapGesture { selectedLink = link; focused = true; hint = "Cable selected · Delete to disconnect · Drag to another input" }
                                .gesture(DragGesture(minimumDistance:4,coordinateSpace:.named("routing"))
                                    .onChanged { value in
                                        guard editable else { return }; selectedLink = link; replacing = link; wiring = link.source; fromInput = false
                                        updateWire(value.location,step:step)
                                    }.onEnded { _ in finishWire() })
                                .accessibilityLabel("Cable row \(link.source%4+1) column \(link.source/4+1) to row \(link.destination%4+1) column \(link.destination/4+1)")
                                .accessibilityAction(named:Text("Disconnect")) { remove(link) }
                        }
                    }
                    ForEach(0..<48,id:\.self) { position in
                        block(position,step:step).position(center(position,step:step))
                    }
                    if let wiring {
                        let fixed = port(wiring,input:fromInput,step:step)
                        cable(fromInput ? pointer : fixed,fromInput ? fixed : pointer)
                            .stroke(validTarget ? StudioTheme.accent : StudioTheme.muted,style:StrokeStyle(lineWidth:2,dash:[5,3]))
                            .allowsHitTesting(false)
                    }
                    if let moving, cells.indices.contains(moving) {
                        artwork(cells[moving].effect).frame(width:step-26,height:48)
                            .background(StudioTheme.raised.opacity(0.9),in:RoundedRectangle(cornerRadius:4))
                            .overlay(RoundedRectangle(cornerRadius:4).stroke(StudioTheme.accent,lineWidth:1.5))
                            .position(pointer).allowsHitTesting(false)
                    }
                }.coordinateSpace(name:"routing")
            }.frame(height:226)
            Text(hint).font(.system(size:11)).foregroundStyle(StudioTheme.muted).lineLimit(1).help(hint)
        }
        .focusable().focused($focused)
        .onDeleteCommand { if let selectedLink { remove(selectedLink) } else { model.removeSelectedBlock() } }
        .onMoveCommand { direction in
            let moving = NSEvent.modifierFlags.contains(.option)
            switch direction {
            case .up: model.navigateGrid(row:-1,column:0,move:moving)
            case .down: model.navigateGrid(row:1,column:0,move:moving)
            case .left: model.navigateGrid(row:0,column:-1,move:moving)
            case .right: model.navigateGrid(row:0,column:1,move:moving)
            @unknown default: break
            }
        }
        .onExitCommand { cancel() }
        .onChange(of:cells) { _ in if let selectedLink, !links.contains(selectedLink) { self.selectedLink = nil } }
        .onChange(of:editable) { value in if !value { cancel() } }
    }
    private func center(_ position: Int, step: CGFloat) -> CGPoint { CGPoint(x:CGFloat(position/4)*step+step/2,y:CGFloat(position%4)*58+26) }
    private func port(_ position: Int, input: Bool, step: CGFloat) -> CGPoint {
        let point = center(position,step:step)
        return CGPoint(x:point.x+(input ? -1 : 1)*(step/2-13),y:point.y)
    }
    private func cellAt(_ point: CGPoint, step: CGFloat) -> Int? {
        guard point.x >= 0, point.x < 12*step, point.y >= 0, point.y < 226 else { return nil }
        return Int(point.x/step)*4+min(3,Int(point.y/58))
    }
    private func cable(_ start: CGPoint,_ end: CGPoint) -> Path {
        var path = Path(); path.move(to:start)
        let bend = max(12,abs(end.x-start.x)*0.5)
        path.addCurve(to:end,control1:CGPoint(x:start.x+bend,y:start.y),control2:CGPoint(x:end.x-bend,y:end.y)); return path
    }
    @ViewBuilder private func artwork(_ effect: Int) -> some View {
        VStack(spacing:0) {
            if effect >= 200 { Image(systemName:"minus").font(.system(size:20)).foregroundStyle(StudioTheme.muted).frame(maxHeight:.infinity) }
            else if effect == 0 { Circle().fill(Color.white.opacity(0.16)).frame(width:3,height:3).frame(maxHeight:.infinity) }
            else {
                DeviceArtwork(type:model.catalog?.effect(effect)?.id ?? "").frame(height:30)
                Text(model.catalog?.name(effect) ?? "Block").font(.system(size:9,weight:.semibold)).lineLimit(1).minimumScaleFactor(0.7).padding(.bottom,3)
            }
        }.frame(maxWidth:.infinity,maxHeight:.infinity)
    }
    private func block(_ position: Int, step: CGFloat) -> some View {
        let effect = cells.indices.contains(position) ? cells[position].effect : 0
        let selected = selectedCell == position
        return ZStack {
            Button {
                focused = true; selectedLink = nil; model.selectedCell = position
                if model.catalog?.effect(effect) != nil { model.showComparison = false; model.selectEffect(effect,cell:position) }
            } label: {
                artwork(effect)
                    .background(effect == 0 || effect >= 200 ? Color.clear : selected ? StudioTheme.raised : StudioTheme.panel,in:RoundedRectangle(cornerRadius:4))
                    .overlay(RoundedRectangle(cornerRadius:4).strokeBorder(selected ? StudioTheme.accent : Color.white.opacity(effect == 0 ? 0 : 0.15),lineWidth:selected ? 1.5 : 1))
            }.buttonStyle(.plain).frame(width:step-26,height:48)
                .opacity(moving == position ? 0.3 : 1)
                .accessibilityLabel("Row \(position%4+1), column \(position/4+1), \(effect == 0 ? "empty" : effect >= 200 ? "shunt" : model.catalog?.name(effect) ?? "Block")")
                .highPriorityGesture(DragGesture(minimumDistance:5,coordinateSpace:.named("routing"))
                    .onChanged { value in
                        guard editable, effect != 0 else { return }
                        focused = true; moving = position; pointer = value.location; target = cellAt(pointer,step:step); detach = NSEvent.modifierFlags.contains(.option); selectedLink = nil
                        if let target, let preset = model.currentPreset {
                            do { _ = try preset.editingGrid(.move(source:position,destination:target,detach:detach)); hint = cells[target].effect == 0 ? "Move to row \(target%4+1), column \(target/4+1)\(detach ? " · detach incompatible cables" : " · settings preserved")" : "Swap blocks · wiring stays at each position" }
                            catch { hint = error.localizedDescription }
                        } else { hint = "Release outside the grid to cancel" }
                    }.onEnded { _ in
                        if let source = moving, let target, validTarget { model.moveBlock(from:source,to:target,detach:detach) }
                        cancel()
                    })
                .overlay(GridContextMenu(model:model,position:position))
            if effect != 0 && connections {
                if position/4 > 0 { socket(position,input:true,step:step).offset(x:-(step/2-13)) }
                if position/4 < 11 { socket(position,input:false,step:step).offset(x:step/2-13) }
            }
        }.frame(width:step,height:52)
    }
    private func socket(_ position: Int, input: Bool, step: CGFloat) -> some View {
        Circle().fill(StudioTheme.background).frame(width:7,height:7)
            .overlay(Circle().stroke(StudioTheme.accent,lineWidth:1.5))
            .frame(width:20,height:24).contentShape(Rectangle())
            .help(input ? "Drag to an output in the previous column" : "Drag to an input in the next column")
            .accessibilityLabel("\(input ? "Input" : "Output") socket row \(position%4+1) column \(position/4+1)")
            .gesture(DragGesture(minimumDistance:2,coordinateSpace:.named("routing"))
                .onChanged { value in
                    guard editable else { return }; wiring = position; fromInput = input; replacing = nil
                    updateWire(value.location,step:step)
                }.onEnded { _ in finishWire() })
    }
    private var pendingLink: GridLink? {
        guard let wiring, let target else { return nil }
        return fromInput ? GridLink(source:target,destination:wiring) : GridLink(source:wiring,destination:target)
    }
    private var validTarget: Bool {
        guard let preset = model.currentPreset, let target else { return false }
        if let moving { return (try? preset.editingGrid(.move(source:moving,destination:target,detach:detach))) != nil }
        if let link = pendingLink { return (try? preset.editingGrid(replacing.map { .reroute($0,to:link) } ?? .link(link,enabled:true))) != nil }
        return false
    }
    private func updateWire(_ point: CGPoint, step: CGFloat) {
        pointer = point; target = cellAt(point,step:step); focused = true
        hint = validTarget ? (replacing == nil ? "Release to connect · drag an existing cable to reroute it" : "Release to reroute this cable") : "Connect sockets in adjacent columns · use shunts to span a gap"
    }
    private func finishWire() {
        if validTarget, let link = pendingLink { model.editGrid(replacing.map { .reroute($0,to:link) } ?? .link(link,enabled:true)); selectedLink = link }
        cancel()
    }
    private func remove(_ link: GridLink) { guard editable else { return }; model.editGrid(.link(link,enabled:false)); selectedLink = nil }
    private func cancel() { moving = nil; wiring = nil; replacing = nil; target = nil; hint = "Drag blocks to move · Arrows select · Option-arrows move · Delete removes" }
}
