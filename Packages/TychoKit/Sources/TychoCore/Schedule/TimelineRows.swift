import Foundation

public enum TimelineGrouping: String, CaseIterable, Sendable, Identifiable {
    case status
    case assignee
    case project
    case none

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .status: "Group: Status"
        case .assignee: "Group: Assignee"
        case .project: "Group: Project"
        case .none: "No grouping"
        }
    }

    public func effective(inProject: Bool) -> TimelineGrouping {
        self == .project && inProject ? .status : self
    }
}

public enum TimelineGroupKind {
    case status(TaskStatus)
    case member(Member)
    case unassigned
    case project(Project)
    case all
}

public struct TimelineGroup: Identifiable {
    public let id: String
    public let kind: TimelineGroupKind
    public let title: String
    public let count: Int
}

public enum TimelineRow: Identifiable {
    case milestones(count: Int)
    case group(TimelineGroup)
    case task(TaskItem)

    public var id: String {
        switch self {
        case .milestones: "milestones"
        case .group(let group): "group.\(group.id)"
        case .task(let task): task.id.uuidString
        }
    }

    public var isHeader: Bool {
        switch self {
        case .task: false
        case .milestones, .group: true
        }
    }
}

public enum TimelineRows {
    private struct Bucket {
        let id: String
        let kind: TimelineGroupKind
        let title: String
        let tasks: [TaskItem]
    }

    public static func build(
        tasks: [TaskItem], grouping: TimelineGrouping, milestoneCount: Int, members: [Member], projects: [Project]
    ) -> [TimelineRow] {
        let scheduled = tasks.filter { $0.due != nil }
        var rows: [TimelineRow] = milestoneCount > 0 ? [.milestones(count: milestoneCount)] : []
        for bucket in buckets(scheduled, grouping: grouping, members: members, projects: projects)
        where !bucket.tasks.isEmpty {
            if grouping != .none {
                rows.append(
                    .group(
                        TimelineGroup(id: bucket.id, kind: bucket.kind, title: bucket.title, count: bucket.tasks.count))
                )
            }
            rows += sorted(bucket.tasks).map(TimelineRow.task)
        }
        return rows
    }

    public static func centers(of rows: [TimelineRow]) -> [UUID: Double] {
        var centers: [UUID: Double] = [:]
        for (index, row) in rows.enumerated() {
            if case .task(let task) = row {
                centers[task.id] = Double(index) * TimelineLayout.rowHeight + TimelineLayout.rowHeight / 2
            }
        }
        return centers
    }

    private static func buckets(
        _ tasks: [TaskItem], grouping: TimelineGrouping, members: [Member], projects: [Project]
    ) -> [Bucket] {
        switch grouping {
        case .status:
            TaskStatus.allCases.map { status in
                Bucket(
                    id: "status.\(status.rawValue)", kind: .status(status), title: status.title,
                    tasks: tasks.filter { $0.status == status })
            }
        case .assignee:
            members.map { member in
                Bucket(
                    id: "member.\(member.id)", kind: .member(member), title: member.name,
                    tasks: tasks.filter { $0.assignee === member })
            } + [
                Bucket(
                    id: "unassigned", kind: .unassigned, title: "Unassigned", tasks: tasks.filter { $0.assignee == nil }
                )
            ]
        case .project:
            projects.map { project in
                Bucket(
                    id: "project.\(project.id)", kind: .project(project), title: project.name,
                    tasks: tasks.filter { $0.project === project })
            }
        case .none:
            [Bucket(id: "all", kind: .all, title: "All tasks", tasks: tasks)]
        }
    }

    private static func sorted(_ tasks: [TaskItem]) -> [TaskItem] {
        tasks.sorted { lhs, rhs in
            let left = lhs.start ?? lhs.due ?? .distantFuture
            let right = rhs.start ?? rhs.due ?? .distantFuture
            return left == right ? lhs.number < rhs.number : left < right
        }
    }
}
