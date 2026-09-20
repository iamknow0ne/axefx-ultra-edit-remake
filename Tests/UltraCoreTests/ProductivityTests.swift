import Foundation
#if !STANDALONE
import XCTest
@testable import UltraCore
#endif
final class ProductivityTests: XCTestCase {
    func testDraftAndEffectCopyPreserveUnknownBytes() throws {
        let catalog = try Catalog(url:URL(fileURLWithPath:"Resources/UltraCatalog.json"))
        let preset = try UltraPreset(message:Array(Data(contentsOf:URL(fileURLWithPath:"Tests/Fixtures/synthetic-preset.syx"))))
        let edited = try preset.settingParameter(effect:106,parameter:1,raw:150,catalog:catalog)
        let range = try XCTUnwrap(preset.parameterRange(effect:106))
        XCTAssertEqual(zip(edited.payload,preset.payload).filter { $0 != $1 }.count,1)
        XCTAssertEqual(edited.payload[range.lowerBound+1],150)
        XCTAssertEqual(try UltraPreset(message:edited.message).payload,edited.payload)
        XCTAssertThrowsError(try preset.settingParameter(effect:106,parameter:0,raw:0,catalog:catalog))
        XCTAssertThrowsError(try preset.settingParameter(effect:139,parameter:1,raw:0,catalog:catalog))
        XCTAssertThrowsError(try preset.settingParameter(effect:106,parameter:250,raw:0,catalog:catalog))
        XCTAssertThrowsError(try preset.settingParameter(effect:106,parameter:1,raw:255,catalog:catalog))
        let setting = try EffectSetting(preset:edited,effect:106,title:"Test",catalog:catalog)
        let copied = try preset.applying(setting,to:106,catalog:catalog)
        XCTAssertEqual(copied.payload,edited.payload)
        XCTAssertThrowsError(try preset.applying(setting,to:108,catalog:catalog))
        XCTAssertTrue(preset.rigSheet(catalog:catalog).contains(preset.fingerprint))
        XCTAssertTrue(preset.rigSheet(catalog:catalog).contains("Drive"))
    }
    func testPortableSetlist() throws {
        let preset = try UltraPreset(message:Array(Data(contentsOf:URL(fileURLWithPath:"Tests/Fixtures/synthetic-preset.syx"))))
        var list = PerformanceSetlist(); let a = SetlistItem(preset:preset,notes:"Capo 2"), b = SetlistItem(preset:try preset.renamed("Song B"))
        list.items = [a,b]; list.move(a.id,by:1); XCTAssertEqual(list.items.first?.id,b.id)
        list.move(a.id,by:1); XCTAssertEqual(list.items.last?.id,a.id)
        let data = try JSONEncoder().encode(list); let decoded = try JSONDecoder().decode(PerformanceSetlist.self,from:data); try decoded.validate()
        XCTAssertEqual(decoded.items.last?.notes,"Capo 2"); XCTAssertEqual(decoded.items.last?.preset?.payload,preset.payload)
        list.items.append(a); XCTAssertThrowsError(try list.validate())
    }
    func testWAVAndImpulsePreparation() throws {
        let impulse = try ImpulseResponse(samples:[1,-0.5,0.25]+Array(repeating:0,count:2045),sampleRate:48000)
        let data = impulse.wavData(), parsed = try ImpulseResponse.readWAV(data)
        XCTAssertEqual(parsed.samples,impulse.samples); XCTAssertEqual(parsed.sampleRate,48000)
        XCTAssertThrowsError(try ImpulseResponse.readWAV(data.dropLast(1)))
        XCTAssertThrowsError(try ImpulseResponse(samples:[.nan],sampleRate:48000))
        let prepared = try impulse.prepared()
        XCTAssertEqual(prepared.samples.count,1024); XCTAssertTrue(abs(prepared.peak-0.95)<1e-9); XCTAssertEqual(prepared.samples.last,0)
        let delayed = try ImpulseResponse(samples:Array(repeating:0,count:100)+impulse.samples,sampleRate:48000)
        XCTAssertEqual(try delayed.prepared().samples,prepared.samples)
        let cancellation = try prepared.blended(with:prepared,mix:0.5,invert:true)
        XCTAssertEqual(cancellation.peak,0)
        let shifted = try prepared.blended(with:prepared,mix:1,delay:5)
        XCTAssertEqual(Array(shifted.samples.prefix(5)),Array(repeating:0,count:5))
        XCTAssertTrue(abs(shifted.samples[5]-prepared.samples[0])<1e-12)
        let short = try ImpulseResponse(samples:[1],sampleRate:44100).prepared()
        XCTAssertEqual(short.samples.count,1024)
        // Downsampling must suppress a signal above the new Nyquist frequency.
        let high = try ImpulseResponse(samples:(0..<8192).map { sin(2 * .pi * 35000 * Double($0)/96000) },sampleRate:96000).prepared(trim:false,normalize:false)
        let low = try ImpulseResponse(samples:(0..<8192).map { sin(2 * .pi * 1000 * Double($0)/96000) },sampleRate:96000).prepared(trim:false,normalize:false)
        let highEnergy = high.samples[100..<900].reduce(0){$0+$1*$1}, lowEnergy = low.samples[100..<900].reduce(0){$0+$1*$1}
        XCTAssertTrue(highEnergy < lowEnergy*0.001)
        let kernel = try ImpulseResponse(samples:[1,0.5],sampleRate:48000)
        let signal = try ImpulseResponse(samples:[1,2,3],sampleRate:48000)
        XCTAssertEqual(try kernel.convolving(audio:signal).samples,[1,2.5,4,1.5])
        let clip = try ImpulseResponse.readWAV(Data(contentsOf:URL(fileURLWithPath:"Tests/Fixtures/audition.wav")))
        XCTAssertTrue(clip.peak > 0.02)
        let longRender = try prepared.convolving(audio:clip)
        XCTAssertEqual(longRender.samples.count,49023); XCTAssertTrue(longRender.peak > 0.001)
        let flat = try ImpulseResponse(samples:[1],sampleRate:48000)
        XCTAssertTrue(abs(flat.magnitudeDB(frequency:1000))<1e-9)
    }
}
