import Foundation
import SwiftData

extension TaskItem {
    public func isBlocked(by other: TaskItem) -> Bool {
        (blockedBy ?? []).contains { $0 === other }
    }
}

@MainActor
public struct DependencyActions {
    private let context: ModelContext
    private let now: () -> Date

    public init(context: ModelContext, now: @escaping () -> Date = { .now }) {
        self.context = context
        self.now = now
    }

    public static func candidates(for task: TaskItem, matching query: String = "") -> [TaskItem] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return (task.project?.tasks ?? [])
            .filter { $0 !== task }
            .filter {
                needle.isEmpty || $0.key.localizedCaseInsensitiveContains(needle)
                    || $0.title.localizedCaseInsensitiveContains(needle)
            }
            .sorted { $0.number < $1.number }
    }

    public func toggle(_ dependency: TaskItem, for task: TaskItem) throws {
        guard dependency !== task else { throw ValidationError.dependencyOnSelf }
        guard let project = task.project, dependency.project === project else {
            throw ValidationError.dependencyAcrossProjects
        }
        var current = task.blockedBy ?? []
        if let index = current.firstIndex(where: { $0 === dependency }) {
            current.remove(at: index)
        } else {
            guard !dependency.isBlocked(by: task) else { throw ValidationError.dependencyCycle }
            current.append(dependency)
        }
        task.blockedBy = current
        task.updatedAt = now()
        try context.saveOrRollback()
    }
}
