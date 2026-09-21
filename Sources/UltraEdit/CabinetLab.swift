import AppKit
import AVFoundation
import SwiftUI
import UniformTypeIdentifiers
import UltraCore

final class CabinetLabModel: ObservableObject {
    @Published var source: ImpulseResponse?
    @Published var second: ImpulseResponse?
    @Published var prepared: ImpulseResponse?
    @Published var sourceName = "No impulse loaded"
    @Published var secondName = "No second impulse"
    @Published var trim = true
    @Published var normalize = true
    @Published var mix = 0.5
    @Published var invert = false
    @Published var delay = 0
    @Published var working = false
    @Published var message = "Open a WAV cabinet impulse, or extract a limited linear response from a NAM model."
    @Published var namReport: NAMLinearization?
    @Published var frequencyPoints: [Double] = []
    @Published var previewReady = false
    @Published var previewName = "No audition clip"
    private var audition: ImpulseResponse?
    var previewAudio: ImpulseResponse?
    private var player: AVAudioPlayer?
    private var process: Process?
    func openWAV(second isSecond: Bool = false) {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [.wav, UTType(filenameExtension:"syx") ?? .data]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let size = try url.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? 0
            guard size <= 32*1024*1024 else { throw MIDIError.message("Choose an impulse file smaller than 32 MB.") }
            let ir = try url.pathExtension.lowercased() == "syx" ? ImpulseResponse(samples:UserCabIR.readFile(Data(contentsOf:url)).samples,sampleRate:48000) : ImpulseResponse.readWAV(Data(contentsOf:url))
            if isSecond { second = ir; secondName = url.lastPathComponent }
            else { source = ir; sourceName = url.lastPathComponent; namReport = nil }
            rebuild()
        } catch { message = error.localizedDescription }
    }
    func loadImportedCabinet(_ entry: SavedCabinet) {
        guard !working, let cab = entry.cabinet else { return }
        do { source = try ImpulseResponse(samples:cab.samples,sampleRate:48000); sourceName = entry.title; namReport = nil; second = nil; rebuild() }
        catch { message = error.localizedDescription }
    }
    func clearBlend() { second = nil; secondName = "No second impulse"; rebuild() }
    func rebuild() {
        do {
            guard let source else { return }
            var output = try source.prepared(trim:trim,normalize:false)
            if let second { output = try output.blended(with:second.prepared(trim:trim,normalize:false),mix:mix,invert:invert,delay:delay) }
            guard output.peak > 1e-12 else { throw MIDIError.message("The blend cancels to silence. Change mix or polarity.") }
            if normalize { output = try ImpulseResponse(samples:output.samples.map { $0/output.peak*0.95 },sampleRate:48000) }
            player?.stop(); previewReady = false; previewAudio = nil
            prepared = output
            if audition != nil { renderAudition() }
            frequencyPoints = (0..<180).map { i in output.magnitudeDB(frequency:20*pow(1000,Double(i)/179)) }
            message = "Prepared 1,024 samples · 48 kHz mono · 21.33 ms. WAV export; user-cab upload is not yet validated."
        } catch { player?.stop(); previewReady = false; previewAudio = nil; prepared = nil; frequencyPoints = []; message = error.localizedDescription }
    }
    func openNAM() {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [UTType(filenameExtension:"nam") ?? .data]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        extractNAM(url)
    }
    func extractNAM(_ url: URL) {
        guard !working else { return }
        working = true; message = "Running NAM locally at two input levels…"
        let helper = Bundle.main.bundleURL.appendingPathComponent("Contents/MacOS/nam-ir")
        let executable = FileManager.default.isExecutableFile(atPath:helper.path) ? helper : URL(fileURLWithPath:FileManager.default.currentDirectoryPath).appendingPathComponent(".build/nam/nam-ir")
        let task = Process(); process = task; task.executableURL = executable
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent("ultra-nam-"+UUID().uuidString)
        DispatchQueue.global(qos:.userInitiated).async { [weak self] in
            do {
                try FileManager.default.createDirectory(at:folder,withIntermediateDirectories:true)
                defer { try? FileManager.default.removeItem(at:folder) }
                let resultURL = folder.appendingPathComponent("response.json"), errorURL = folder.appendingPathComponent("error.txt")
                FileManager.default.createFile(atPath:errorURL.path,contents:nil)
                let errorFile = try FileHandle(forWritingTo:errorURL); defer { try? errorFile.close() }
                task.arguments = [url.path,resultURL.path]; task.standardError = errorFile; task.standardOutput = errorFile
                try task.run()
                let timeout = DispatchWorkItem { if task.isRunning { task.terminate() } }
                DispatchQueue.global().asyncAfter(deadline:.now()+90,execute:timeout)
                task.waitUntilExit(); timeout.cancel()
                guard task.terminationStatus == 0 else {
                    let info = (try? String(contentsOf:errorURL,encoding:.utf8)) ?? ""
                    throw MIDIError.message("NAM extraction stopped or this model is unsupported. " + String(info.suffix(1800)))
                }
                let report = try JSONDecoder().decode(NAMLinearization.self,from:Data(contentsOf:resultURL))
                let impulse = try report.impulse
                guard report.levelSensitivityPercent.isFinite else { throw MIDIError.message("Invalid NAM response.") }
                DispatchQueue.main.async {
                    self?.source = impulse; self?.sourceName = url.lastPathComponent + " · linear approximation"
                    self?.namReport = report; self?.working = false; self?.process = nil; self?.rebuild()
                }
            } catch {
                DispatchQueue.main.async { self?.working = false; self?.process = nil; self?.message = error.localizedDescription }
            }
        }
    }
    func cancel() { process?.terminate() }
    func openAudition() {
        let panel = NSOpenPanel(); panel.allowedContentTypes = [.wav]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        loadAudition(url)
    }
    func loadAudition(_ url: URL) {
        do {
            let size = try url.resourceValues(forKeys:[.fileSizeKey]).fileSize ?? 0
            guard size < 8*1024*1024 else { throw MIDIError.message("Choose a 48 kHz WAV clip up to 15 seconds.") }
            let clip = try ImpulseResponse.readWAV(Data(contentsOf:url))
            guard clip.sampleRate == 48000, clip.durationMS <= 15000 else { throw MIDIError.message("Audition clips must be 48 kHz and no longer than 15 seconds.") }
            guard clip.peak > 1e-8 else { throw MIDIError.message("The audition clip is silent. Choose a recording with audio.") }
            audition = clip; previewName = url.lastPathComponent; renderAudition()
        } catch { message = error.localizedDescription }
    }
    func renderAudition() {
        guard let prepared, let audition else { return }
        do {
            let audio = try prepared.convolving(audio:audition)
            // Fixed attenuation only when needed to avoid clipping; no boost.
            let gain = min(1,0.9/max(audio.peak,1e-12))
            previewAudio = try ImpulseResponse(samples:audio.samples.map { $0 * gain },sampleRate:48000)
            previewReady = true
        } catch { previewReady = false; message = error.localizedDescription }
    }
    func playPreview(dry: Bool) {
        do {
            guard let audio = dry ? audition : previewAudio else { return }
            player?.stop(); player = try AVAudioPlayer(data:audio.wavData()); player?.volume = 0.35
            guard player?.play() == true else { throw MIDIError.message("macOS could not start audio playback.") }
            message = dry ? "Playing dry audition clip at 35% playback volume." : "Playing through the prepared cabinet at 35% playback volume."
        } catch { message = error.localizedDescription }
    }
    func stopPreview() { player?.stop() }
    func exportPreview() {
        guard let previewAudio else { return }
        let panel = NSSavePanel(); panel.allowedContentTypes = [.wav]; panel.nameFieldStringValue = "Cabinet-audition.wav"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do { try previewAudio.wavData().write(to:url,options:.atomic); message = "Exported cabinet audition; peak protection was applied if needed." } catch { message = error.localizedDescription }
    }
    func export() {
        guard let prepared else { return }
        let panel = NSSavePanel(); panel.allowedContentTypes = [.wav]
        panel.nameFieldStringValue = namReport == nil ? "Ultra-Cab-48k.wav" : "NAM-linear-approximation-48k.wav"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            try prepared.wavData().write(to:url,options:.atomic)
            message = "Exported \(url.lastPathComponent). " + (namReport == nil ? "48 kHz mono float WAV." : "Linear filtering only; NAM distortion and dynamics are not included.")
        } catch { message = error.localizedDescription }
    }
}

struct CabinetLabView: View {
    var model: EditorModel? = nil
    @State private var userSlot = 10
    @ObservedObject var lab: CabinetLabModel
    var body: some View {
        VStack(alignment:.leading,spacing:16) {
            HStack {
                Button("Open WAV / .syx…") { lab.openWAV() }.disabled(lab.working)
                Button("Extract from NAM…",action:lab.openNAM).disabled(lab.working)
                if lab.working { ProgressView().controlSize(.small); Button("Cancel",action:lab.cancel) }
                Spacer()
                Button("Export WAV…",action:lab.export).disabled(lab.prepared == nil || lab.working)
            }
            if let model, !model.importedCabinets.isEmpty {
                Menu("Imported cabinets (\(model.importedCabinets.count))") {
                    ForEach(model.importedCabinets) { entry in Button(entry.title) { lab.loadImportedCabinet(entry) } }
                }.disabled(lab.working)
            }
            Group {
            Text(lab.sourceName).font(.title3.weight(.semibold)).textSelection(.enabled)
            if let report = lab.namReport {
                VStack(alignment:.leading,spacing:6) {
                    Label("NAM linear approximation",systemImage:"waveform.path").font(.headline)
                    Text("This captures filtering around silence. It does not reproduce distortion, compression, or playing dynamics.")
                    Text(String(format:"Response changes %.1f%% between the two probe levels. This is a sensitivity measure, not a tone-match score.",report.levelSensitivityPercent)).font(.caption).foregroundStyle(StudioTheme.muted)
                }.padding(12).background(StudioTheme.raised)
            }
            if let output = lab.prepared {
                VStack(alignment:.leading,spacing:8) {
                    Text("IMPULSE · 0–21.33 ms").font(.caption.monospaced()).foregroundStyle(StudioTheme.muted)
                    impulsePlot(output).frame(height:110)
                    Text("FREQUENCY RESPONSE · 20 Hz–20 kHz · relative to peak · −60…0 dB").font(.caption.monospaced()).foregroundStyle(StudioTheme.muted)
                    frequencyPlot.frame(height:140)
                }.padding(16).background(StudioTheme.background)
                HStack { Text("48,000 Hz"); Text("1,024 samples"); Text(String(format:"Peak %.3f",output.peak)); Spacer() }.font(.system(.caption,design:.monospaced))
            } else {
                VStack(spacing:12) { Image(systemName:"waveform").font(.system(size:46)); Text("Your cabinet workbench").font(.title2); Text("Prepare and blend mono impulses for export. Stereo WAV files use the left channel.").foregroundStyle(StudioTheme.muted) }.frame(maxWidth:.infinity,minHeight:210)
            }
            HStack {
                Toggle("Trim leading silence",isOn:$lab.trim).onChange(of:lab.trim) { _ in lab.rebuild() }
                Toggle("Normalize to 95% peak",isOn:$lab.normalize).onChange(of:lab.normalize) { _ in lab.rebuild() }
            }
            HStack {
                Stepper("User Cab \(userSlot)",value:$userSlot,in:1...10)
                Button("Export Ultra .syx…") { lab.exportUserCab(slot:userSlot) }.disabled(lab.prepared == nil || lab.working)
                if let model {
                    Button("Upload to Ultra…") {
                        do { if let ir = lab.prepared { model.uploadUserCab(try UserCabIR(samples:ir.samples,sampleRate:Int(ir.sampleRate)),slot:userSlot) } } catch { lab.message = error.localizedDescription }
                    }.disabled(!model.canOperate || lab.prepared == nil || lab.working)
                }
            }
            if let model {
                HStack {
                    Button("Upload original .syx…") { model.uploadOriginalUserCab(slot:userSlot) }.disabled(!model.canOperate || lab.working)
                    Button("Select in Cabinet 1") { model.selectUserCab(slot:userSlot) }.disabled(!model.canOperate || lab.working)
                }
            }
            Text("Gen-1 user-cab transfer is experimental. It overwrites the selected User Cab; keep its original .syx. NAM extraction preserves only a linear approximation, never its distortion or dynamics.").font(.caption).foregroundStyle(StudioTheme.muted)
            Divider()
            HStack { Text("CABINET BLEND").font(.caption.bold()); Spacer(); Button("Add second WAV…") { lab.openWAV(second:true) }; if lab.second != nil { Button("Remove",action:lab.clearBlend) } }
            if lab.second != nil {
                Text(lab.secondName).font(.caption).foregroundStyle(StudioTheme.muted)
                HStack { Text("A"); Slider(value:$lab.mix,in:0...1,onEditingChanged:{ if !$0 { lab.rebuild() } }).accessibilityLabel("Second cabinet mix"); Text(String(format:"B %.0f%%",lab.mix*100)).frame(width:65) }
                HStack { Toggle("Invert B polarity",isOn:$lab.invert).onChange(of:lab.invert) { _ in lab.rebuild() }; Spacer(); Stepper("B delay: \(lab.delay) samples",value:$lab.delay,in:0...256).onChange(of:lab.delay) { _ in lab.rebuild() } }
            }
            Divider()
            HStack {
                Button("Load audition WAV…",action:lab.openAudition).disabled(lab.prepared == nil)
                Button("Dry") { lab.playPreview(dry:true) }.disabled(!lab.previewReady)
                Button("Through cab") { lab.playPreview(dry:false) }.disabled(!lab.previewReady)
                Button("Stop",action:lab.stopPreview)
                Button("Export audio…",action:lab.exportPreview).disabled(!lab.previewReady)
            }
            Text("Audition: 48 kHz, ≤15 s. Use an amp recording without a cab. NAM distortion is not rendered.").font(.caption).foregroundStyle(StudioTheme.muted)
            Text(lab.message).font(.caption).foregroundStyle(StudioTheme.muted).textSelection(.enabled)
            Spacer(minLength:0)
            }.disabled(lab.working)
        }.onDisappear { lab.stopPreview() }
    }
    func impulsePlot(_ ir: ImpulseResponse) -> some View {
        Canvas { context,size in
            var zero = Path(); zero.move(to:.init(x:0,y:size.height/2)); zero.addLine(to:.init(x:size.width,y:size.height/2)); context.stroke(zero,with:.color(.gray.opacity(0.4)))
            var path = Path()
            for (i,x) in ir.samples.enumerated() { let p = CGPoint(x:Double(i)/Double(ir.samples.count-1)*size.width,y:size.height/2-x/max(ir.peak,1e-12)*size.height*0.45); if i==0 { path.move(to:p) } else { path.addLine(to:p) } }
            context.stroke(path,with:.color(StudioTheme.accent),lineWidth:1)
        }.accessibilityLabel("Impulse waveform, 1,024 samples over 21.33 milliseconds")
    }
    var frequencyPlot: some View {
        Canvas { context,size in
            for division in 0...4 { var line = Path(); let y = Double(division)/4*size.height; line.move(to:.init(x:0,y:y)); line.addLine(to:.init(x:size.width,y:y)); context.stroke(line,with:.color(.gray.opacity(0.2))) }
            let maximum = lab.frequencyPoints.max() ?? 0
            var path = Path()
            for (i,value) in lab.frequencyPoints.enumerated() { let p = CGPoint(x:Double(i)/Double(max(1,lab.frequencyPoints.count-1))*size.width,y:min(60,max(0,maximum-value))/60*size.height); if i==0 { path.move(to:p) } else { path.addLine(to:p) } }
            context.stroke(path,with:.color(StudioTheme.accent),lineWidth:2)
        }.accessibilityLabel("Relative frequency response, logarithmic 20 hertz to 20 kilohertz")
    }
}
