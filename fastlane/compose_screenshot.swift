import Foundation
import CoreGraphics
import CoreText
import ImageIO
import UniformTypeIdentifiers

// Frames a raw simulator screenshot for the App Store: teal ground, a
// headline and subline at the top, the screen below with rounded corners
// and a soft shadow. Output is the same 1320×2868 the input has.
//
//   swift compose_screenshot.swift <in.png> <out.png> "<headline>" "<subline>"

let args = CommandLine.arguments
guard args.count == 5 else {
    FileHandle.standardError.write("usage: compose_screenshot.swift in out headline subline\n".data(using: .utf8)!)
    exit(1)
}
let (inPath, outPath, headline, subline) = (args[1], args[2], args[3], args[4])

let cs = CGColorSpace(name: CGColorSpace.sRGB)!
func rgba(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> CGColor {
    CGColor(colorSpace: cs, components: [r, g, b, a])!
}

guard let source = CGImageSourceCreateWithURL(URL(fileURLWithPath: inPath) as CFURL, nil),
      let screen = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
    FileHandle.standardError.write("cannot read \(inPath)\n".data(using: .utf8)!)
    exit(1)
}

let width = screen.width
let height = screen.height
let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0,
                    space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!

// Ground: same teal family as the icon, lighter bloom top-left.
let base = CGGradient(colorsSpace: cs,
                      colors: [rgba(0.15, 0.54, 0.50), rgba(0.08, 0.33, 0.31)] as CFArray,
                      locations: [0, 1])!
ctx.drawLinearGradient(base, start: CGPoint(x: 0, y: CGFloat(height)), end: CGPoint(x: CGFloat(width), y: 0), options: [])
let bloom = CGGradient(colorsSpace: cs,
                       colors: [rgba(0.45, 0.85, 0.78, 0.40), rgba(0.45, 0.85, 0.78, 0)] as CFArray,
                       locations: [0, 1])!
ctx.drawRadialGradient(bloom, startCenter: CGPoint(x: 260, y: CGFloat(height) - 200), startRadius: 0,
                       endCenter: CGPoint(x: 260, y: CGFloat(height) - 200), endRadius: 1100, options: [])

// Text block at the top.
func draw(_ text: String, size: CGFloat, weight: CGFloat, y: CGFloat, alpha: CGFloat) -> CGFloat {
    let font = CTFontCreateWithName("HelveticaNeue-Bold" as CFString, size, nil)
    let descriptor = CTFontDescriptorCreateWithAttributes([
        kCTFontFamilyNameAttribute: ".AppleSystemUIFont",
        kCTFontTraitsAttribute: [kCTFontWeightTrait: weight]
    ] as CFDictionary)
    let systemFont = CTFontCreateWithFontDescriptor(descriptor, size, nil)
    let useFont = CTFontCopyFamilyName(systemFont) as String == ".AppleSystemUIFont" ? systemFont : font

    var alignment = CTTextAlignment.center
    var spacing = size * 0.12
    let settings = [
        CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: &alignment),
        CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout<CGFloat>.size, value: &spacing)
    ]
    let paragraph = CTParagraphStyleCreate(settings, settings.count)
    let attributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key(kCTFontAttributeName as String): useFont,
        NSAttributedString.Key(kCTForegroundColorAttributeName as String): rgba(0.99, 0.98, 0.95, alpha),
        NSAttributedString.Key(kCTParagraphStyleAttributeName as String): paragraph
    ]
    let attributed = NSAttributedString(string: text, attributes: attributes)
    let framesetter = CTFramesetterCreateWithAttributedString(attributed)
    let inset: CGFloat = 110
    let box = CGSize(width: CGFloat(width) - inset * 2, height: 600)
    let fitted = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRange(location: 0, length: 0), nil, box, nil)
    let rect = CGRect(x: inset, y: y - fitted.height, width: box.width, height: fitted.height)
    let path = CGPath(rect: rect, transform: nil)
    let frame = CTFramesetterCreateFrame(framesetter, CFRange(location: 0, length: 0), path, nil)
    ctx.saveGState()
    ctx.textMatrix = .identity
    CTFrameDraw(frame, ctx)
    ctx.restoreGState()
    return rect.minY
}

var cursor = CGFloat(height) - 250
cursor = draw(headline, size: 96, weight: 0.62, y: cursor, alpha: 1)
cursor -= 28
cursor = draw(subline, size: 48, weight: 0.0, y: cursor, alpha: 0.82)

// Screen: scaled, rounded, shadowed, hanging off the bottom edge.
let scale: CGFloat = 0.84
let screenWidth = CGFloat(width) * scale
let screenHeight = CGFloat(height) * scale
let screenX = (CGFloat(width) - screenWidth) / 2
let screenTop = cursor - 90
let screenY = screenTop - screenHeight   // may be negative: bottom is cropped by the canvas
let screenRect = CGRect(x: screenX, y: screenY, width: screenWidth, height: screenHeight)
let corner: CGFloat = 120 * scale

ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: -30), blur: 80, color: rgba(0, 0.08, 0.08, 0.5))
ctx.setFillColor(rgba(0.05, 0.2, 0.19))
ctx.addPath(CGPath(roundedRect: screenRect, cornerWidth: corner, cornerHeight: corner, transform: nil))
ctx.fillPath()
ctx.restoreGState()

ctx.saveGState()
ctx.addPath(CGPath(roundedRect: screenRect, cornerWidth: corner, cornerHeight: corner, transform: nil))
ctx.clip()
ctx.draw(screen, in: screenRect)
ctx.restoreGState()

// Thin bezel line so the screen edge reads on the teal.
ctx.saveGState()
ctx.setStrokeColor(rgba(1, 1, 1, 0.22))
ctx.setLineWidth(4)
ctx.addPath(CGPath(roundedRect: screenRect.insetBy(dx: 2, dy: 2), cornerWidth: corner, cornerHeight: corner, transform: nil))
ctx.strokePath()
ctx.restoreGState()

let image = ctx.makeImage()!
let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outPath) as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(dest, image, nil)
CGImageDestinationFinalize(dest)
