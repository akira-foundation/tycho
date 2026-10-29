import Foundation

public struct TaskViewQuery: Sendable {
    public var query: String
    public var filters: [TaskFilter]
    public var sort: TaskComparator?

    public init(query: String = "", filters: [TaskFilter] = [], sort: TaskComparator? = nil) {
        self.query = query
        self.filters = filters
        self.sort = sort
    }

    public func apply(_ tasks: [TaskItem], now: Date, calendar: Calendar) -> [TaskItem] {
        let filtered = tasks.filter { task in
            filters.allSatisfy { $0.matches(task, now: now, calendar: calendar) }
        }
        return TableSort.sorted(searched(filtered), by: sort.map { [$0] } ?? [])
    }

    private func searched(_ tasks: [TaskItem]) -> [TaskItem] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return tasks }
        return tasks.filter {
            $0.title.lowercased().contains(needle) || $0.key.lowercased().contains(needle)
        }
    }
}
