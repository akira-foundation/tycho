import TychoCore

enum ListDropPolicy {
    static func allowsReorder(sort: [TaskComparator], grouping: TaskViewGrouping) -> Bool {
        let first = sort.first ?? TaskComparator(field: .manual)
        return allowsStatusChange(grouping: grouping) && first.field == .manual && first.order == .forward
    }

    static func allowsStatusChange(grouping: TaskViewGrouping) -> Bool {
        grouping == .status
    }
}
