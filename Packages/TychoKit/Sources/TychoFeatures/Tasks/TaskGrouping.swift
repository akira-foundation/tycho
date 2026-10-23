import TychoCore

struct TaskGroup: Identifiable {
    let status: TaskStatus
    let tasks: [TaskItem]

    var id: TaskStatus { status }
}

enum TaskGrouping {
    static func byStatus(_ tasks: [TaskItem]) -> [TaskGroup] {
        TaskStatus.allCases.map { status in
            TaskGroup(
                status: status, tasks: tasks.filter { $0.status == status }.sorted { $0.sortOrder < $1.sortOrder })
        }
    }
}
