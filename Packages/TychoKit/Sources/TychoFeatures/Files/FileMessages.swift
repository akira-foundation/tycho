import Foundation
import TychoCore

enum FileMessages {
    static func meta(_ file: FileRecord, dateText: DateText) -> String {
        "\(file.sizeText) · \(file.uploadedBy?.firstName ?? "You") · \(dateText.ago(file.uploadedAt))"
    }

    static func previewSubtitle(_ file: FileRecord, dateText: DateText) -> String {
        "\(file.kind.title) · \(file.sizeText) · Uploaded by \(file.uploadedBy?.name ?? "you") \(dateText.ago(file.uploadedAt))"
    }

    static func deleteMessage(_ file: FileRecord) -> String {
        "\(file.name) will be removed from the project\(file.task == nil ? "" : " and its task")."
    }

    static func link(_ file: FileRecord) -> String {
        "tycho://file/\(file.id.uuidString)"
    }
}
