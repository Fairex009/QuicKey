import AppKit
import Foundation

// Deterministic, offline 1024px QuicKey icon, with a full-bleed opaque background.
// This script runs on the GitHub macOS runner before XcodeGen generates the project.
guard CommandLine.arguments.count == 2 else {
    fatalError("Usage: swift scripts/generate_app_icon.swift <output.png>")
}
let output = URL(fileURLWithPath: CommandLine.arguments[1])
try FileManager.default.createDirectory(at: output.deletingLastPathComponent(),
                                        withIntermediateDirectories: true)
let size = 1024
// CoreGraphics can allocate a bitmap on a headless GitHub runner. Using an
// RGBX color space produces an opaque asset without an alpha channel.
guard let bitmapContext = CGContext(data: nil, width: size, height: size,
                                    bitsPerComponent: 8, bytesPerRow: 0,
                                    space: CGColorSpaceCreateDeviceRGB(),
                                    bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
    fatalError("Unable to allocate CoreGraphics image context")
}
let graphics = NSGraphicsContext(cgContext: bitmapContext, flipped: false)
func color(_ r: Int, _ g: Int, _ b: Int) -> NSColor {
    NSColor(calibratedRed: CGFloat(r)/255, green: CGFloat(g)/255,
            blue: CGFloat(b)/255, alpha: 1)
}
func rounded(_ rect: NSRect, _ radius: CGFloat, fill: NSColor, stroke: NSColor? = nil,
             lineWidth: CGFloat = 1) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    fill.setFill()
    path.fill()
    if let stroke {
        stroke.setStroke()
        path.lineWidth = lineWidth
        path.stroke()
    }
}
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = graphics

let background = NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1024, height: 1024))
NSGradient(starting: color(6, 35, 82), ending: color(18, 14, 70))?
    .draw(in: background, angle: -39)

// Broad orbital trails echo the gradient palette used by the FAIREX keyboard.
let trail = NSBezierPath()
trail.move(to: NSPoint(x: 145, y: 325))
trail.curve(to: NSPoint(x: 870, y: 824),
            controlPoint1: NSPoint(x: 255, y: 950),
            controlPoint2: NSPoint(x: 860, y: 962))
trail.lineWidth = 36
trail.lineCapStyle = .round
color(24, 217, 219).withAlphaComponent(0.48).setStroke()
trail.stroke()

let lowerTrail = NSBezierPath()
lowerTrail.move(to: NSPoint(x: 175, y: 205))
lowerTrail.curve(to: NSPoint(x: 910, y: 355),
                   controlPoint1: NSPoint(x: 480, y: 60),
                   controlPoint2: NSPoint(x: 735, y: 180))
lowerTrail.lineWidth = 30
lowerTrail.lineCapStyle = .round
color(139, 92, 246).withAlphaComponent(0.58).setStroke()
lowerTrail.stroke()

rounded(NSRect(x: 88, y: 207, width: 848, height: 606), 140,
        fill: color(9, 18, 60), stroke: color(26, 219, 226), lineWidth: 23)
rounded(NSRect(x: 119, y: 235, width: 786, height: 548), 109,
        fill: color(8, 32, 79), stroke: color(114, 113, 250), lineWidth: 13)

for row in 0..<2 {
    for column in 0..<5 {
        let x: CGFloat = 187 + CGFloat(column) * 135
        let y: CGFloat = 604 - CGFloat(row) * 120
        rounded(NSRect(x: x, y: y, width: 105, height: 85), 22,
                fill: color(189 + 6 * column, 218, 252),
                stroke: color(233, 247, 255), lineWidth: 4)
    }
}
rounded(NSRect(x: 175, y: 304, width: 190, height: 136), 29,
        fill: color(12, 169, 140), stroke: color(26, 229, 195), lineWidth: 7)
rounded(NSRect(x: 390, y: 304, width: 302, height: 136), 29,
        fill: color(129, 190, 246), stroke: color(194, 225, 255), lineWidth: 7)
rounded(NSRect(x: 717, y: 304, width: 144, height: 136), 29,
        fill: color(127, 42, 219), stroke: color(192, 133, 255), lineWidth: 7)

// Direction key chevron.
let arrow = NSBezierPath()
arrow.move(to: NSPoint(x: 243, y: 338))
arrow.line(to: NSPoint(x: 292, y: 371))
arrow.line(to: NSPoint(x: 243, y: 408))
arrow.lineWidth = 18
arrow.lineCapStyle = .round
arrow.lineJoinStyle = .round
NSColor.white.setStroke()
arrow.stroke()

// Lightning key, kept recognizable at compact icon sizes.
let lightning = NSBezierPath()
lightning.move(to: NSPoint(x: 800, y: 423))
lightning.line(to: NSPoint(x: 766, y: 368))
lightning.line(to: NSPoint(x: 796, y: 368))
lightning.line(to: NSPoint(x: 782, y: 325))
lightning.line(to: NSPoint(x: 832, y: 391))
lightning.line(to: NSPoint(x: 800, y: 391))
lightning.close()
NSColor.white.setFill()
lightning.fill()

graphics.flushGraphics()
NSGraphicsContext.restoreGraphicsState()
guard let image = bitmapContext.makeImage(),
      let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode PNG")
}
try data.write(to: output, options: [.atomic])
print("PASS QuicKey icon: \(size)x\(size), opaque PNG at \(output.path)")
