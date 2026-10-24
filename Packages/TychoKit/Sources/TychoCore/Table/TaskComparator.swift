import Foundation

public enum TaskSortField: String, Codable, Sendable {
    case manual
    case title
    case status
    case priority
    case assignee
    case due
    case start
    case estimate
    case created
    case project
}

public struct TaskComparator: SortComparator, Codable, Hashable, Sendable {
    public var field: TaskSortField
    public var order: SortOrder

    public init(field: TaskSortField, order: SortOrder = .forward) {
        self.field = field
        self.order = order
    }

    public func compare(_ lhs: TaskItem, _ rhs: TaskItem) -> ComparisonResult {
        let result = ascending(lhs, rhs)
        guard order == .reverse else { return result }
        switch result {
        case .orderedAscending: return .orderedDescending
        case .orderedDescending: return .orderedAscending
        case .orderedSame: return .orderedSame
        }
    }

    private func ascending(_ lhs: TaskItem, _ rhs: TaskItem) -> ComparisonResult {
        switch field {
        case .manual: Self.rank(lhs.sortOrder, rhs.sortOrder)
        case .title: Self.rank(lhs.title.lowercased(), rhs.title.lowercased())
        case .status: Self.rank(Self.statusIndex(lhs), Self.statusIndex(rhs))
        case .priority: Self.rank(-lhs.priority.weight, -rhs.priority.weight)
        case .assignee: Self.rank(lhs.assignee?.name ?? "zzz", rhs.assignee?.name ?? "zzz")
        case .due: Self.rank(lhs.due ?? .distantFuture, rhs.due ?? .distantFuture)
        case .start: Self.rank(lhs.start ?? .distantFuture, rhs.start ?? .distantFuture)
        case .estimate: Self.rank(lhs.estimate ?? "zzz", rhs.estimate ?? "zzz")
        case .created: Self.rank(rhs.createdAt, lhs.createdAt)
        case .project: Self.rank(lhs.project?.name ?? "", rhs.project?.name ?? "")
        }
    }

    private static func statusIndex(_ task: TaskItem) -> Int {
        TaskStatus.allCases.firstIndex(of: task.status) ?? 0
    }

    private static func rank<Value: Comparable>(_ lhs: Value, _ rhs: Value) -> ComparisonResult {
        switch (lhs < rhs, rhs < lhs) {
        case (true, _): .orderedAscending
        case (_, true): .orderedDescending
        default: .orderedSame
        }
    }
}

public enum TableSort {
    public static func sorted(_ tasks: [TaskItem], by comparators: [TaskComparator]) -> [TaskItem] {
        tasks.sorted(using: comparators + [TaskComparator(field: .manual)])
    }
}
