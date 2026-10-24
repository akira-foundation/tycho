import Foundation
import TychoCore

enum FileQuickLook {
    struct MissingContent: Error {}

    static func temporaryURL(for file: FileRecord, in base: URL = FileManager.default.temporaryDirectory) throws -> URL
    {
        guard file.hasData, let data = file.data else { throw MissingContent() }
        let directory = base.appending(path: "tycho-files").appending(path: file.id.uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let url = directory.appending(path: file.name.replacingOccurrences(of: "/", with: "-"))
        try data.write(to: url, options: .atomic)
        return url
    }
}
