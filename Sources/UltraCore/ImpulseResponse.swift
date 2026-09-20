import Foundation
import Accelerate

public struct ImpulseResponse {
    public let samples: [Double]
    public let sampleRate: Double
    public init(samples: [Double], sampleRate: Double) throws {
        guard !samples.isEmpty, samples.count <= 2_000_000, samples.allSatisfy(\.isFinite), (8000...192000).contains(sampleRate) else { throw MIDIError.message("Invalid impulse: finite samples and an 8–192 kHz sample rate are required.") }
        self.samples = samples; self.sampleRate = sampleRate
    }
    public var peak: Double { samples.map(abs).max() ?? 0 }
    public var durationMS: Double { Double(samples.count)/sampleRate*1000 }
    public static func readWAV(_ data: Data, channel: Int = 0) throws -> ImpulseResponse {
        let b = Array(data)
        func tag(_ n: Int) -> String { String(bytes:b[n..<n+4],encoding:.ascii) ?? "" }
        func u16(_ n: Int) -> Int { Int(b[n]) | Int(b[n+1])<<8 }
        func u32(_ n: Int) -> UInt32 { UInt32(b[n]) | UInt32(b[n+1])<<8 | UInt32(b[n+2])<<16 | UInt32(b[n+3])<<24 }
        guard b.count >= 44, b.count <= 32*1024*1024, tag(0) == "RIFF", tag(8) == "WAVE", Int(u32(4))+8 == b.count else { throw MIDIError.message("Choose a complete PCM or float WAV file, up to 32 MB.") }
        var format: (kind:Int,channels:Int,rate:Int,bits:Int,align:Int)?, audio: Range<Int>?
        var offset = 12
        while offset+8 <= b.count {
            let size = Int(u32(offset+4)), start = offset+8
            guard size <= b.count-start else { throw MIDIError.message("Truncated WAV chunk.") }
            if tag(offset) == "fmt ", size >= 16 { format = (u16(start),u16(start+2),Int(u32(start+4)),u16(start+14),u16(start+12)) }
            if tag(offset) == "data" { audio = start..<start+size }
            offset = start+size+(size%2)
        }
        guard let f = format, let audio, (1...2).contains(f.channels), (0..<f.channels).contains(channel),
              (f.kind == 1 && [16,24,32].contains(f.bits) || f.kind == 3 && f.bits == 32),
              f.align == f.channels*f.bits/8, audio.count%f.align == 0 else { throw MIDIError.message("Supported WAV: mono/stereo PCM 16/24/32-bit or float32. Stereo import uses the left channel.") }
        var samples = [Double](); samples.reserveCapacity(audio.count/f.align)
        for start in stride(from:audio.lowerBound,to:audio.upperBound,by:f.align) {
            let p = start+channel*f.bits/8
            if f.kind == 3 { samples.append(Double(Float(bitPattern:u32(p)))) }
            else if f.bits == 16 { samples.append(Double(Int16(bitPattern:UInt16(u16(p))))/32768) }
            else if f.bits == 24 {
                var v = Int32(b[p]) | Int32(b[p+1])<<8 | Int32(b[p+2])<<16
                if v & 0x800000 != 0 { v |= ~0xFFFFFF }
                samples.append(Double(v)/8388608)
            } else { samples.append(Double(Int32(bitPattern:u32(p)))/2147483648) }
        }
        return try ImpulseResponse(samples:samples,sampleRate:Double(f.rate))
    }
    public func wavData() -> Data {
        var result = Data()
        func ascii(_ s:String) { result.append(contentsOf:s.utf8) }
        func u16(_ x:UInt16) { result.append(UInt8(x&255)); result.append(UInt8(x>>8)) }
        func u32(_ x:UInt32) { for shift in stride(from:0,to:32,by:8) { result.append(UInt8((x>>shift)&255)) } }
        ascii("RIFF"); u32(UInt32(36+samples.count*4)); ascii("WAVEfmt "); u32(16); u16(3); u16(1)
        u32(UInt32(sampleRate)); u32(UInt32(sampleRate)*4); u16(4); u16(32); ascii("data"); u32(UInt32(samples.count*4))
        for sample in samples { u32(Float(sample).bitPattern) }
        return result
    }
    /// Windowed-sinc resampling with an anti-alias low-pass for downsampling.
    public func prepared(length: Int = 1024, trim: Bool = true, normalize: Bool = true) throws -> ImpulseResponse {
        let sourcePeak = peak
        guard [1024,2048,4096].contains(length), sourcePeak > 1e-12 else { throw MIDIError.message("The impulse is silent, or the requested length is unsupported.") }
        let first = trim ? (samples.firstIndex(where:{ abs($0) >= sourcePeak*0.0001 }) ?? 0) : 0
        let source = Array(samples[first...]), ratio = sampleRate/48000, cutoff = min(1,48000/sampleRate)*0.95
        var out = [Double](repeating:0,count:length)
        for i in 0..<length {
            if sampleRate == 48000 { out[i] = i < source.count ? source[i] : 0; continue }
            let pos = Double(i)*ratio, center = Int(pos), radius = 48
            if center >= source.count+radius { break }
            let lower = max(0,center-radius), upper = min(source.count-1,center+radius)
            guard lower <= upper else { continue }
            for j in lower...upper {
                let x = pos-Double(j)
                if abs(x) >= Double(radius) { continue }
                let sinc = abs(x)<1e-12 ? cutoff : sin(.pi*x*cutoff)/(.pi*x)
                let window = 0.5+0.5*cos(.pi*x/Double(radius))
                out[i] += source[j]*sinc*window
            }
        }
        // Fade only the tail: retain the impulse attack at index zero.
        let fade = min(64,length/8)
        for i in 0..<fade { out[length-fade+i] *= 0.5+0.5*cos(.pi*Double(i)/Double(fade-1)) }
        let outputPeak = out.map(abs).max() ?? 0
        if normalize && outputPeak > 1e-12 { out = out.map { $0/outputPeak*0.95 } }
        return try ImpulseResponse(samples:out,sampleRate:48000)
    }
    public func blended(with other: ImpulseResponse, mix: Double, invert: Bool = false, delay: Int = 0) throws -> ImpulseResponse {
        guard sampleRate == other.sampleRate, (0...1).contains(mix), (0...256).contains(delay) else { throw MIDIError.message("Blend requires matching sample rates and a valid mix/delay.") }
        let out = samples.enumerated().map { i,x -> Double in
            let j = i-delay, y = other.samples.indices.contains(j) ? other.samples[j] : 0
            return x*(1-mix)+y*mix*(invert ? -1:1)
        }
        return try ImpulseResponse(samples:out,sampleRate:sampleRate)
    }
    public func magnitudeDB(frequency: Double) -> Double {
        var re = 0.0, im = 0.0
        for (i,x) in samples.enumerated() { let angle = 2*Double.pi*frequency*Double(i)/sampleRate; re += x*cos(angle); im -= x*sin(angle) }
        return 20*log10(max(1e-8,hypot(re,im)))
    }
}
public struct NAMLinearization: Decodable {
    public let sampleRate: Double
    public let samples: [Double]
    public let levelSensitivityPercent: Double
    public let method: String
    public let limitation: String
    public var impulse: ImpulseResponse { get throws { try ImpulseResponse(samples:samples,sampleRate:sampleRate) } }
}

public extension ImpulseResponse {
    /// Offline convolution for audition files, never on an audio callback.
    func convolving(audio: ImpulseResponse) throws -> ImpulseResponse {
        guard sampleRate == audio.sampleRate, samples.count <= 4096, audio.samples.count <= Int(sampleRate*15) else { throw MIDIError.message("Audition requires a mono WAV at 48 kHz, no longer than 15 seconds.") }
        let count = audio.samples.count+samples.count-1
        var output = [Double](repeating:0,count:count)
        // vDSP computes a sliding dot product; reversed kernel gives convolution.
        let padded = Array(repeating:0.0,count:samples.count-1)+audio.samples+Array(repeating:0.0,count:samples.count-1)
        padded.withUnsafeBufferPointer { a in
            samples.withUnsafeBufferPointer { f in
                output.withUnsafeMutableBufferPointer { c in
                    vDSP_convD(a.baseAddress!,1,f.baseAddress!+samples.count-1,-1,c.baseAddress!,1,vDSP_Length(count),vDSP_Length(samples.count))
                }
            }
        }
        return try ImpulseResponse(samples:output,sampleRate:sampleRate)
    }
}
