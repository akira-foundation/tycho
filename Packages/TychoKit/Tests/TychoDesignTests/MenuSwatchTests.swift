import CoreGraphics
import SwiftUI
import Testing

@testable import TychoDesign

struct MenuSwatchTests {
    private func pixel(_ image: CGImage, x: Int, y: Int) -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: 4)
        let space = CGColorSpace(name: CGColorSpace.sRGB)!
        bytes.withUnsafeMutableBytes { buffer in
            let context = CGContext(
                data: buffer.baseAddress, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: space,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            context.draw(
                image, in: CGRect(x: -x, y: -(image.height - 1 - y), width: image.width, height: image.height))
        }
        return bytes
    }

    @Test func bitmapKeepsTheColourItWasGiven() throws {
        let rose = Color.Resolved(colorSpace: .sRGB, red: 0xC5 / 255, green: 0x4B / 255, blue: 0x78 / 255)
        let image = try #require(MenuSwatch.bitmap(rose, side: 20))

        #expect(image.width == 20)
        #expect(image.height == 20)
        #expect(pixel(image, x: 10, y: 10) == [0xC5, 0x4B, 0x78, 0xFF])
    }

    @Test func bitmapLeavesTheCornersClear() throws {
        let image = try #require(MenuSwatch.bitmap(Color.Resolved(red: 0, green: 0, blue: 1), side: 20))

        #expect(pixel(image, x: 0, y: 0)[3] == 0)
    }

    @Test func bitmapRefusesAnEmptySide() {
        #expect(MenuSwatch.bitmap(Color.Resolved(red: 1, green: 0, blue: 0), side: 0) == nil)
    }
}
