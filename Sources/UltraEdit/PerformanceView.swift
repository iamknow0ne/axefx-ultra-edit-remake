import SwiftUI

struct PerformanceView: View {
    @ObservedObject var model: EditorModel
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            Text("PERFORMANCE").font(.caption.bold()).tracking(1)
            HStack {
                Button("Tap tempo",action:model.tapTempo).disabled(!model.canOperate || !model.performanceMappingConfirmed)
                TimelineView(.periodic(from:.now,by:0.5)) { context in
                    Text(model.tempoAt.map { context.date.timeIntervalSince($0) < 4 } == true ? model.observedBPM.map { String(format:"≈ %.0f BPM",$0) } ?? "Waiting for next beat" : "No recent tempo pulse").font(.body.monospaced())
                }
            }
            Divider()
            TimelineView(.periodic(from:.now,by:0.2)) { context in
                let fresh = model.tunerAt.map { context.date.timeIntervalSince($0) < 1.5 } == true
                VStack(spacing:12) {
                    Text(fresh ? model.tunerReading?.noteName ?? "—" : "—").font(.system(size:64,weight:.medium,design:.rounded))
                    if fresh, let reading = model.tunerReading {
                        Text(String(format:"%+d cents",reading.cents)).font(.title3.monospaced()).foregroundStyle(abs(reading.cents) <= 2 ? .green : StudioTheme.accent)
                        GeometryReader { g in
                            ZStack {
                                Rectangle().fill(StudioTheme.muted).frame(height:1)
                                Rectangle().fill(StudioTheme.text).frame(width:1,height:20)
                                Circle().fill(abs(reading.cents) <= 2 ? .green : StudioTheme.accent).frame(width:12,height:12).offset(x:CGFloat(max(-50,min(50,reading.cents)))/100*(g.size.width-12))
                            }.frame(height:24)
                        }.frame(height:24)
                    } else { Text("Open the Ultra’s tuner and play a note").foregroundStyle(StudioTheme.muted) }
                }.frame(maxWidth:.infinity).frame(height:180)
            }
            HStack { Button("Tuner on") { model.setTuner(true) }; Button("Tuner off") { model.setTuner(false) } }.disabled(!model.canOperate || !model.performanceMappingConfirmed)
            Text("The meter follows the Ultra’s tuning and mute settings. Stale readings disappear automatically.").font(.caption).foregroundStyle(StudioTheme.muted)
            Divider()
            HStack { Stepper("Tap CC \(model.tapCC)",value:$model.tapCC,in:1...127); Stepper("Tuner CC \(model.tunerCC)",value:$model.tunerCC,in:1...127) }
                .onChange(of:model.tapCC) { _ in model.performanceMappingConfirmed = false }.onChange(of:model.tunerCC) { _ in model.performanceMappingConfirmed = false }
            Toggle("These CC numbers match the Ultra’s I/O → CTRL assignments",isOn:$model.performanceMappingConfirmed).font(.caption)
            Text("Defaults are 14 and 15. Check custom assignments before sending. Incoming tempo and tuner displays work without sending CCs.").font(.caption).foregroundStyle(StudioTheme.muted)
        }.padding(20).frame(width:420).background(StudioTheme.panel).foregroundStyle(StudioTheme.text).preferredColorScheme(.dark)
    }
}
