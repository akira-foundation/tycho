import Foundation
import SwiftData

@Model
public final class FileRecord {
    public var id: UUID = UUID()
    public var name: String = ""
    public var typeRaw: String = FileKind.other.rawValue
    public var byteCount: Int = 0
    public var uploadedAt: Date = Date.now
    public var hasData: Bool = false
    @Attribute(.externalStorage) public var data: Data?
    public var project: Project?
    public var task: TaskItem?
    public var uploadedBy: Member?

    public init(name: String, byteCount: Int, uploadedAt: Date) {
        self.name = name
        self.typeRaw = FileKind.from(fileName: name).rawValue
        self.byteCount = byteCount
        self.uploadedAt = uploadedAt
    }

    public var kind: FileKind {
        get { FileKind(rawValue: typeRaw) ?? .other }
        set { typeRaw = newValue.rawValue }
    }

    public var sizeText: String { ByteCountText.format(byteCount) }

    public var fileExtension: String { FileName.extension(of: name) }
}
