import Foundation
import SwiftData

@MainActor
public struct FileActions {
    public nonisolated static let maxByteCount = 250 * 1_048_576

    private let context: ModelContext
    private let now: () -> Date

    public init(context: ModelContext, now: @escaping () -> Date = { .now }) {
        self.context = context
        self.now = now
    }

    @discardableResult
    public func add(
        name: String, data: Data, to project: Project, task: TaskItem?, by member: Member?
    ) throws
        -> FileRecord
    {
        let clean = try Self.cleanName(name)
        guard data.count <= Self.maxByteCount else { throw ValidationError.fileTooLarge }
        return try insert(name: clean, data: data, byteCount: data.count, project: project, task: task, by: member)
    }

    public func rename(_ file: FileRecord, to name: String) throws {
        file.name = try Self.cleanName(name)
        file.kind = FileKind.from(fileName: file.name)
        try context.saveOrRollback()
    }

    @discardableResult
    public func duplicate(_ file: FileRecord, by member: Member?) throws -> FileRecord {
        try insert(
            name: FileName.duplicateName(of: file.name), data: file.hasData ? file.data : nil,
            byteCount: file.byteCount, project: file.project, task: file.task, by: member)
    }

    public func delete(_ file: FileRecord) throws {
        context.delete(file)
        try context.saveOrRollback()
    }

    private func insert(
        name: String, data: Data?, byteCount: Int, project: Project?, task: TaskItem?, by member: Member?
    ) throws -> FileRecord {
        let file = FileRecord(name: name, byteCount: byteCount, uploadedAt: now())
        file.data = data
        file.hasData = data != nil
        context.insert(file)
        file.project = project
        file.task = task
        file.uploadedBy = member
        try context.saveOrRollback()
        return file
    }

    static func cleanName(_ raw: String) throws -> String {
        let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw ValidationError.emptyName }
        return name
    }
}
