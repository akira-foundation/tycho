import Foundation
import TychoCore

enum MyTaskGroups {
    static let initiallyCollapsed: Set<String> = ["completed"]

    static func groups(_ tasks: [TaskItem], now: Date, calendar: Calendar) -> [TaskViewGroup] {
        let open = tasks.filter { $0.status != .done }
        let offset: (TaskItem) -> Int? = { $0.dayOffset(now: now, calendar: calendar) }
        return [
            TaskViewGroup(id: "overdue", title: "Overdue", tasks: open.filter { (offset($0) ?? 0) < 0 }),
            TaskViewGroup(id: "today", title: "Today", tasks: open.filter { offset($0) == 0 }),
            TaskViewGroup(id: "upcoming", title: "Upcoming", tasks: open.filter { (offset($0) ?? 1) > 0 }),
            TaskViewGroup(id: "completed", title: "Completed", tasks: tasks.filter { $0.status == .done }),
        ]
    }

    static func query(for state: TaskViewState) -> TaskViewQuery {
        var query = state.viewQuery
        if (query.sort?.field ?? .manual) == .manual {
            query.sort = TaskComparator(field: .due)
        }
        return query
    }
}
