import Foundation
import TychoCore

enum FileImport {
    static func read(_ url: URL) throws -> (name: String, data: Data) {
        let scoped = url.startAccessingSecurityScopedResource()
        defer {
            if scoped { url.stopAccessingSecurityScopedResource() }
        }
        let values = try url.resourceValues(forKeys: [.isRegularFileKey, .fileSizeKey])
        guard values.isRegularFile == true else { throw ValidationError.unsupportedFile }
        guard (values.fileSize ?? 0) <= FileActions.maxByteCount else { throw ValidationError.fileTooLarge }
        return (url.lastPathComponent, try Data(contentsOf: url))
    }
}
