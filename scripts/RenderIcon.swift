import AppKit
import SwiftUI

@main struct RenderIcon {
    @MainActor static func main() throws {
        let directory = URL(fileURLWithPath:".build/UltraEdit.iconset")
        try FileManager.default.createDirectory(at:directory,withIntermediateDirectories:true)
        for size in [16,32,128,256,512] {
            for scale in [1,2] {
                let pixels = size*scale
                let content = ZStack {
                    RoundedRectangle(cornerRadius:210).fill(StudioTheme.background)
                    RoundedRectangle(cornerRadius:205).strokeBorder(Color.white.opacity(0.15),lineWidth:12).padding(15)
                    VStack(spacing:0) {
                        DeviceArtwork(type:"Amp").frame(width:900,height:540)
                        Text("ULTRA").font(.system(size:105,weight:.bold,design:.rounded)).tracking(22).foregroundStyle(StudioTheme.accent)
                    }
                }.frame(width:1024,height:1024).scaleEffect(CGFloat(pixels)/1024).frame(width:CGFloat(pixels),height:CGFloat(pixels))
                let renderer = ImageRenderer(content:content)
                guard let cg = renderer.cgImage, let data = NSBitmapImageRep(cgImage:cg).representation(using:.png,properties:[:]) else { throw NSError(domain:"Icon render",code:1) }
                try data.write(to:directory.appendingPathComponent("icon_\(size)x\(size)\(scale == 2 ? "@2x" : "").png"))
            }
        }
    }
}
