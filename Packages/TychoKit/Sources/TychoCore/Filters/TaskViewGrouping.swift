import Foundation

public enum TaskViewGrouping: String, Codable, CaseIterable, Sendable {
    case status
    case priority
    case assignee
    case project
    case due
    case none

    public var title: String {
        switch self {
        case .status: "Status"
        case .priority: "Priority"
        case .assignee: "Assignee"
        case .project: "Project"
        case .due: "Due date"
        case .none: "No grouping"
        }
    }

    public func groups(
        _ tasks: [TaskItem], members: [Member], projects: [Project], now: Date, calendar: Calendar
    ) -> [TaskViewGroup] {
        switch self {
        case .none:
            return [TaskViewGroup(id: "all", title: "All tasks", tasks: tasks)]
        case .status:
            return TaskStatus.allCases.map { status in
                TaskViewGroup(id: status.rawValue, title: status.title, tasks: tasks.filter { $0.status == status })
            }
        case .priority:
            return TaskPriority.allCases.map { priority in
                TaskViewGroup(
                    id: priority.rawValue, title: priority.title, tasks: tasks.filter { $0.priority == priority })
            }
        case .assignee:
            return nonEmpty(assigneeGroups(tasks, members: members))
        case .project:
            return nonEmpty(projectGroups(tasks, projects: projects))
        case .due:
            return nonEmpty(dueGroups(tasks, now: now, calendar: calendar))
        }
    }

    private func nonEmpty(_ groups: [TaskViewGroup]) -> [TaskViewGroup] {
        groups.filter { !$0.tasks.isEmpty }
    }

    private func assigneeGroups(_ tasks: [TaskItem], members: [Member]) -> [TaskViewGroup] {
        let ordered = members.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        let named = ordered.map { member in
            TaskViewGroup(
                id: member.id.uuidString, title: member.name,
                tasks: tasks.filter { $0.assignee?.id == member.id })
        }
        let unassigned = TaskViewGroup(
            id: TaskFilter.noAssignee, title: "Unassigned", tasks: tasks.filter { $0.assignee == nil })
        return named + [unassigned]
    }

    private func projectGroups(_ tasks: [TaskItem], projects: [Project]) -> [TaskViewGroup] {
        projects.sorted { $0.sortOrder < $1.sortOrder }.map { project in
            TaskViewGroup(
                id: project.id.uuidString, title: project.name,
                tasks: tasks.filter { $0.project?.id == project.id })
        }
    }

    private func dueGroups(_ tasks: [TaskItem], now: Date, calendar: Calendar) -> [TaskViewGroup] {
        let placed = tasks.map { task -> (TaskItem, DueBucket?) in
            let buckets = DueBucket.bucket(for: task, now: now, calendar: calendar)
            return (task, DueBucket.allCases.first(where: buckets.contains))
        }
        return DueBucket.allCases.map { bucket in
            TaskViewGroup(
                id: bucket.rawValue, title: bucket.title,
                tasks: placed.filter { $0.1 == bucket }.map(\.0))
        }
    }
}

public struct TaskViewGroup: Identifiable {
    public let id: String
    public let title: String
    public let tasks: [TaskItem]

    public init(id: String, title: String, tasks: [TaskItem]) {
        self.id = id
        self.title = title
        self.tasks = tasks
    }
}
