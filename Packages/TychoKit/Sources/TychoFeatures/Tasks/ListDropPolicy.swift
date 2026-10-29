import TychoCore

enum ListDropPolicy {
    static func allowsReorder(sort: [TaskComparator], grouping: TaskViewGrouping) -> Bool {
        allowsStatusChange(grouping: grouping) && (sort.first?.field ?? .manual) == .manual
    }

    static func allowsStatusChange(grouping: TaskViewGrouping) -> Bool {
        grouping == .status
    }
}
