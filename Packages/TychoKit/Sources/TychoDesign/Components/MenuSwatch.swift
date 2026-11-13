import CoreGraphics
import SwiftUI

public enum MenuSwatch {
    public static let diameter: CGFloat = 10

    public static func image(_ color: Color.Resolved, diameter: CGFloat = diameter, scale: CGFloat = 2) -> Image {
        guard let bitmap = bitmap(color, side: Int((diameter * scale).rounded(.up))) else {
            return Image(systemName: "circle.fill")
        }
        return Image(decorative: bitmap, scale: scale).renderingMode(.original)
    }

    static func bitmap(_ color: Color.Resolved, side: Int) -> CGImage? {
        guard side > 0, let space = CGColorSpace(name: CGColorSpace.sRGB),
            let context = CGContext(
                data: nil, width: side, height: side, bitsPerComponent: 8, bytesPerRow: 0, space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return nil }
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(x: 0, y: 0, width: side, height: side))
        return context.makeImage()
    }
}
