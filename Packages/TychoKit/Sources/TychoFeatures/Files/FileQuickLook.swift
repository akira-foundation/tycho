import Foundation
import SwiftData
import TychoCore

enum FileQuickLook {
    struct MissingContent: Error {}

    static let maxNameByteCount = 255

    private static let directoryName = "tycho-files"

    static func temporaryURL(
        forFileID fileID: UUID, container: ModelContainer, in base: URL = FileManager.default.temporaryDirectory
    ) async throws -> URL {
        try await Task.detached(priority: .userInitiated) {
            let context = ModelContext(container)
            var descriptor = FetchDescriptor<FileRecord>(predicate: #Predicate { $0.id == fileID })
            descriptor.fetchLimit = 1
            guard let file = try context.fetch(descriptor).first, file.hasData, let data = file.data else {
                throw MissingContent()
            }
            return try write(data, named: file.name, in: base)
        }.value
    }

    private static func write(_ data: Data, named name: String, in base: URL) throws -> URL {
        let directory = base.appending(path: directoryName).appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appending(path: safeName(name))
        try data.write(to: url, options: .atomic)
        return url
    }

    static func cleanUp(_ url: URL) {
        let directory = url.deletingLastPathComponent()
        guard directory.deletingLastPathComponent().lastPathComponent == directoryName else { return }
        try? FileManager.default.removeItem(at: directory)
    }

    static func sweep(in base: URL = FileManager.default.temporaryDirectory) {
        try? FileManager.default.removeItem(at: base.appending(path: directoryName))
    }

    static func safeName(_ name: String) -> String {
        let cleaned = name.replacingOccurrences(of: "/", with: "-").replacingOccurrences(of: "\0", with: "")
        guard !["", ".", ".."].contains(cleaned) else { return "file" }
        return truncated(cleaned)
    }

    private static func truncated(_ name: String) -> String {
        guard name.utf8.count > maxNameByteCount else { return name }
        let fileExtension = FileName.extension(of: name)
        let suffix = fileExtension.isEmpty ? "" : "." + String(name.suffix(fileExtension.count))
        let keptSuffix = suffix.utf8.count < maxNameByteCount ? suffix : ""
        var stem = String(name.dropLast(keptSuffix.count))
        while stem.utf8.count + keptSuffix.utf8.count > maxNameByteCount { stem.removeLast() }
        return stem.isEmpty ? "file" + keptSuffix : stem + keptSuffix
    }
}
