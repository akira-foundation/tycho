import Foundation
import TychoCore

enum FileQuickLook {
    struct MissingContent: Error {}

    private static let directoryName = "tycho-files"

    static func temporaryURL(for file: FileRecord, in base: URL = FileManager.default.temporaryDirectory) throws -> URL
    {
        guard file.hasData, let data = file.data else { throw MissingContent() }
        let directory = copyDirectory(for: file, in: base)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appending(path: safeName(file.name))
        try data.write(to: url, options: .atomic)
        return url
    }

    static func cleanUp(_ file: FileRecord, in base: URL = FileManager.default.temporaryDirectory) {
        try? FileManager.default.removeItem(at: copyDirectory(for: file, in: base))
    }

    static func sweep(in base: URL = FileManager.default.temporaryDirectory) {
        try? FileManager.default.removeItem(at: base.appending(path: directoryName))
    }

    private static func copyDirectory(for file: FileRecord, in base: URL) -> URL {
        base.appending(path: directoryName).appending(path: file.id.uuidString)
    }

    private static func safeName(_ name: String) -> String {
        let cleaned = name.replacingOccurrences(of: "/", with: "-")
        return ["", ".", ".."].contains(cleaned) ? "file" : cleaned
    }
}
