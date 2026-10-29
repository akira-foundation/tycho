import Foundation
import TychoCore

struct TaskGroup: Identifiable {
    let status: TaskStatus
    let tasks: [TaskItem]

    var id: TaskStatus { status }
}

enum TaskGrouping {
    static func statusGroups(_ tasks: [TaskItem]) -> [TaskViewGroup] {
        TaskViewGrouping.status.groups(
            TableSort.sorted(tasks, by: []), members: [], projects: [], now: .now, calendar: DateText.gregorian)
    }

    static func byStatus(_ tasks: [TaskItem]) -> [TaskGroup] {
        statusGroups(tasks).compactMap { group in
            TaskStatus(rawValue: group.id).map { TaskGroup(status: $0, tasks: group.tasks) }
        }
    }
}
