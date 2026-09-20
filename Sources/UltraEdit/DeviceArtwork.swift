import SwiftUI

/// Original vector illustrations; families, not manufacturer product likenesses.
enum StudioTheme {
    static let background = Color(red:0.094,green:0.110,blue:0.125)
    static let panel = Color(red:0.137,green:0.157,blue:0.176)
    static let raised = Color(red:0.188,green:0.212,blue:0.235)
    static let text = Color(red:0.933,green:0.941,blue:0.925)
    static let muted = Color(red:0.678,green:0.710,blue:0.733)
    static let accent = Color(red:0.894,green:0.671,blue:0.416)
    static func color(_ type: String) -> Color {
        switch type {
        case "Amp": return Color(red:0.83,green:0.61,blue:0.32)
        case "Cab", "Rotary": return Color(red:0.67,green:0.55,blue:0.40)
        case "Drive": return Color(red:0.83,green:0.37,blue:0.23)
        case "Delay", "MultiDelay", "MegaTap": return Color(red:0.32,green:0.67,blue:0.65)
        case "Reverb", "Pitch", "Resonator": return Color(red:0.45,green:0.60,blue:0.78)
        case "Chorus", "Flanger", "Phaser", "QuadChorus", "PanTrem": return Color(red:0.54,green:0.70,blue:0.47)
        default: return Color(red:0.59,green:0.65,blue:0.70)
        }
    }
}

struct DeviceArtwork: View {
    let type: String
    var body: some View {
        Canvas { c, size in
            let scale = min(size.width/180,size.height/100)
            c.translateBy(x:(size.width-180*scale)/2,y:(size.height-100*scale)/2)
            c.scaleBy(x:scale,y:scale)
            let color = StudioTheme.color(type)
            let ink = Color(red:0.065,green:0.075,blue:0.08)
            let metal = Color(red:0.65,green:0.67,blue:0.66)
            func box(_ r: CGRect, _ fill: Color, radius: CGFloat = 3, border: Color = .clear) {
                let p = Path(roundedRect:r,cornerRadius:radius); c.fill(p,with:.color(fill)); c.stroke(p,with:.color(border),lineWidth:1)
            }
            func line(_ a: CGPoint,_ b: CGPoint,_ color: Color,_ width: CGFloat = 1) {
                var p = Path(); p.move(to:a); p.addLine(to:b); c.stroke(p,with:.color(color),lineWidth:width)
            }
            func circle(_ x: CGFloat,_ y: CGFloat,_ radius: CGFloat,_ fill: Color) { c.fill(Path(ellipseIn:CGRect(x:x-radius,y:y-radius,width:radius*2,height:radius*2)),with:.color(fill)) }
            func knob(_ x: CGFloat,_ y: CGFloat,_ radius: CGFloat = 5) { circle(x,y,radius+1,metal.opacity(0.6)); circle(x,y,radius,ink); line(CGPoint(x:x,y:y),CGPoint(x:x+radius*0.5,y:y-radius*0.65),.white,1.2) }
            func text(_ value: String,_ x: CGFloat,_ y: CGFloat,_ size: CGFloat = 7,_ color: Color = .white) { c.draw(Text(value).font(.system(size:size,weight:.bold,design:.monospaced)).foregroundColor(color),at:CGPoint(x:x,y:y)) }
            func speaker(_ x: CGFloat,_ y: CGFloat,_ radius: CGFloat) { circle(x,y,radius,ink); circle(x,y,radius-3,Color(white:0.23)); for i in [5.0,8.0,11.0] where radius > i { c.stroke(Path(ellipseIn:CGRect(x:x-radius+CGFloat(i),y:y-radius+CGFloat(i),width:2*(radius-CGFloat(i)),height:2*(radius-CGFloat(i)))),with:.color(Color(white:0.30)),lineWidth:0.8) }; circle(x,y,radius*0.25,ink) }
            switch type {
            case "Amp":
                box(CGRect(x:61,y:7,width:58,height:9),ink,radius:4,border:metal)
                box(CGRect(x:14,y:17,width:152,height:74),ink,radius:5,border:Color(white:0.36))
                box(CGRect(x:19,y:23,width:142,height:29),color,radius:1)
                text("ULTRA AMPLIFICATION",89,29,6,ink)
                for x in stride(from:CGFloat(36),through:132,by:16) { knob(x,43,4) }
                circle(149,42,2.4,Color(red:0.75,green:0.15,blue:0.12))
                box(CGRect(x:21,y:56,width:138,height:29),Color(white:0.19),radius:1)
                for x in stride(from:CGFloat(24),to:158,by:4) { line(CGPoint(x:x,y:57),CGPoint(x:x,y:84),Color(white:0.31),0.7) }
                text("ULTRA",91,70,11,Color(white:0.82))
                box(CGRect(x:28,y:91,width:18,height:4),ink); box(CGRect(x:134,y:91,width:18,height:4),ink)
            case "Cab", "Rotary":
                box(CGRect(x:38,y:6,width:104,height:90),ink,radius:5,border:color)
                box(CGRect(x:44,y:12,width:92,height:76),color.opacity(0.55),radius:1)
                for x in [CGFloat(66),CGFloat(114)] { for y in [CGFloat(33),CGFloat(68)] { speaker(x,y,17) } }
                for x in stride(from:CGFloat(45),to:136,by:3) { line(CGPoint(x:x,y:13),CGPoint(x:x,y:87),metal.opacity(0.16),0.7) }
                text(type == "Rotary" ? "ROTARY" : "ULTRA CAB",90,91,5)
            case "Wah", "VolPan":
                box(CGRect(x:62,y:4,width:56,height:92),color,radius:5,border:metal)
                box(CGRect(x:67,y:9,width:46,height:72),ink,radius:4)
                for y in stride(from:CGFloat(15),to:79,by:5) { line(CGPoint(x:72,y:y),CGPoint(x:108,y:y),Color(white:0.35),2) }
                text(type == "Wah" ? "WAH" : "VOLUME",90,90,7,ink)
            case "Drive", "Chorus", "Flanger", "Phaser", "PanTrem", "Compressor", "Filter", "RingMod", "Formant", "GateExpander":
                box(CGRect(x:58,y:5,width:64,height:91),color,radius:5,border:color.opacity(0.6))
                for x in [CGFloat(73),CGFloat(106)] { knob(x,23,6) }
                circle(90,40,2,ink)
                text(type == "Compressor" ? "COMP" : type.uppercased(),90,53,type.count > 9 ? 5 : 7,ink)
                box(CGRect(x:65,y:64,width:50,height:24),ink,radius:2)
                circle(90,76,6,metal); circle(90,76,4,Color(white:0.8))
                box(CGRect(x:52,y:43,width:6,height:10),metal,radius:1); box(CGRect(x:122,y:43,width:6,height:10),metal,radius:1)
            case "GraphicEQ", "ParametricEQ", "Mixer", "Crossover", "MultibandComp":
                box(CGRect(x:7,y:22,width:166,height:57),ink,radius:3,border:metal.opacity(0.5))
                box(CGRect(x:20,y:27,width:140,height:46),color.opacity(0.45),radius:1)
                for (i,x) in stride(from:CGFloat(33),through:147,by:14).enumerated() {
                    line(CGPoint(x:x,y:32),CGPoint(x:x,y:67),ink,3)
                    box(CGRect(x:x-4,y:CGFloat([43,37,48,53,39,46,36,50,43][i])-2,width:8,height:5),metal,radius:1)
                }
                for x in [CGFloat(13),CGFloat(167)] { circle(x,32,2,metal); circle(x,69,2,metal) }
            case "Synth", "Vocoder", "Controllers":
                box(CGRect(x:22,y:13,width:136,height:76),ink,radius:4,border:metal.opacity(0.4))
                for x in stride(from:CGFloat(35),to:150,by:16) { knob(x,30,4) }
                for i in 0..<12 { box(CGRect(x:27+CGFloat(i)*10.5,y:47,width:9.5,height:36),Color(white:0.85),radius:0) }
                for i in [0,1,3,4,5,7,8,10] { box(CGRect(x:33+CGFloat(i)*10.5,y:47,width:6,height:23),ink,radius:0) }
            default:
                box(CGRect(x:6,y:23,width:168,height:55),ink,radius:3,border:metal.opacity(0.5))
                box(CGRect(x:21,y:29,width:78,height:42),color.opacity(0.65),radius:2)
                text(type.uppercased(),60,43,type.count > 10 ? 6 : 8,ink)
                var wave = Path(); wave.move(to:CGPoint(x:28,y:60))
                for x in 0..<64 { wave.addLine(to:CGPoint(x:CGFloat(28)+CGFloat(x),y:CGFloat(60+sin(Double(x)*0.3)*4))) }
                c.stroke(wave,with:.color(ink.opacity(0.6)),lineWidth:1)
                knob(120,48,10); knob(148,48,7)
                for x in [CGFloat(13),CGFloat(167)] { circle(x,33,2,metal); circle(x,68,2,metal) }
            }
        }
        .accessibilityHidden(true)
    }
}

struct DialFace: View {
    let fraction: Double
    let color: Color
    var body: some View {
        Canvas { context,size in
            let center = CGPoint(x:size.width/2,y:size.height/2), radius = min(size.width,size.height)/2-5
            var arc = Path(); arc.addArc(center:center,radius:radius,startAngle:.degrees(135),endAngle:.degrees(405),clockwise:false)
            context.stroke(arc,with:.color(Color.white.opacity(0.15)),style:StrokeStyle(lineWidth:2.5,lineCap:.round))
            var active = Path(); active.addArc(center:center,radius:radius,startAngle:.degrees(135),endAngle:.degrees(135+270*min(1,max(0,fraction))),clockwise:false)
            context.stroke(active,with:.color(color),style:StrokeStyle(lineWidth:2.5,lineCap:.round))
            context.fill(Path(ellipseIn:CGRect(x:center.x-radius+5,y:center.y-radius+5,width:2*(radius-5),height:2*(radius-5))),with:.color(StudioTheme.background))
            let angle = (135+270*min(1,max(0,fraction)))*Double.pi/180
            var needle = Path(); needle.move(to:CGPoint(x:center.x+CGFloat(cos(angle))*7,y:center.y+CGFloat(sin(angle))*7)); needle.addLine(to:CGPoint(x:center.x+CGFloat(cos(angle))*(radius-8),y:center.y+CGFloat(sin(angle))*(radius-8)))
            context.stroke(needle,with:.color(StudioTheme.text),style:StrokeStyle(lineWidth:2,lineCap:.round))
        }.accessibilityHidden(true)
    }
}
