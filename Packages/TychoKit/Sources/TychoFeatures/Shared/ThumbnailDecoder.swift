import Foundation
import ImageIO
import SwiftData
import TychoCore
import UniformTypeIdentifiers

enum ThumbnailDecoder {
    static let defaultMaxPixelSize = 960
    static let allowedTypes: [UTType] = [.png, .jpeg, .heic, .gif, .webP, .tiff]

    static func decode(_ data: Data, maxPixelSize: Int = defaultMaxPixelSize, fileName: String? = nil) -> CGImage? {
        var sourceOptions: [CFString: Any] = [:]
        if let hint = typeHint(for: fileName) {
            sourceOptions[kCGImageSourceTypeIdentifierHint] = hint
        }
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions as CFDictionary),
            isAllowed(CGImageSourceGetType(source) as String?)
        else { return nil }
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize,
        ]
        return CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary)
    }

    static func isAllowed(_ identifier: String?) -> Bool {
        guard let identifier, let type = UTType(identifier) else { return false }
        return allowedTypes.contains { type.conforms(to: $0) }
    }

    static func thumbnail(for id: PersistentIdentifier, container: ModelContainer) async -> CGImage? {
        await Task.detached(priority: .utility) {
            let context = ModelContext(container)
            guard let file = context.model(for: id) as? FileRecord, file.kind == .img, file.hasData,
                let data = file.data
            else { return nil }
            return decode(data, fileName: file.name)
        }.value
    }

    private static func typeHint(for fileName: String?) -> String? {
        guard let fileName else { return nil }
        let pathExtension = FileName.extension(of: fileName)
        return UTType(filenameExtension: pathExtension)?.identifier
    }
}
