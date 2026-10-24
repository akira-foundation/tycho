import Foundation
import ImageIO

enum ThumbnailDecoder {
    static let defaultMaxPixelSize = 960

    static func decode(_ data: Data, maxPixelSize: Int = defaultMaxPixelSize) -> CGImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    static func decodeOffMainActor(_ data: Data) async -> CGImage? {
        await Task.detached(priority: .utility) { decode(data) }.value
    }
}
