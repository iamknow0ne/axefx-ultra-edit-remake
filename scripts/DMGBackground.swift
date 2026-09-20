import AppKit

let size = NSSize(width:720,height:540)
let image = NSImage(size:size)
image.lockFocus()
NSColor(calibratedRed:0.96,green:0.96,blue:0.94,alpha:1).setFill()
NSBezierPath(rect:NSRect(origin:.zero,size:size)).fill()
NSColor(calibratedRed:0.10,green:0.12,blue:0.13,alpha:1).setFill()
NSBezierPath(rect:NSRect(x:0,y:390,width:720,height:150)).fill()
func text(_ value:String,x:CGFloat,y:CGFloat,size:CGFloat,color:NSColor,weight:NSFont.Weight = .regular) {
    (value as NSString).draw(at:NSPoint(x:x,y:y),withAttributes:[.font:NSFont.systemFont(ofSize:size,weight:weight),.foregroundColor:color])
}
let amber = NSColor(calibratedRed:0.9,green:0.68,blue:0.38,alpha:1)
text("ULTRA EDIT",x:44,y:483,size:16,color:amber,weight:.bold)
text("Your Ultra. A native Mac workspace.",x:44,y:441,size:26,color:.white,weight:.semibold)
text("Drag Ultra Edit to Applications to install.",x:44,y:410,size:14,color:NSColor(white:0.77,alpha:1))
let arrow = NSBezierPath()
arrow.move(to:NSPoint(x:310,y:295));arrow.line(to:NSPoint(x:410,y:295))
arrow.move(to:NSPoint(x:400,y:305));arrow.line(to:NSPoint(x:410,y:295));arrow.line(to:NSPoint(x:400,y:285))
amber.setStroke();arrow.lineWidth=3;arrow.stroke()
text("Apple Silicon  ·  macOS 13+",x:44,y:28,size:12,color:.darkGray)
text("0.5.0 beta  ·  Read first-launch instructions below",x:350,y:28,size:12,color:.darkGray)
image.unlockFocus()
let bitmap = NSBitmapImageRep(data:image.tiffRepresentation!)!
try bitmap.representation(using:.png,properties:[:])!.write(to:URL(fileURLWithPath:CommandLine.arguments[1]))
