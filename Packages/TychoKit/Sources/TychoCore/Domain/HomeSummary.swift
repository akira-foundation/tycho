import Foundation

public struct HomeSummary {
    public let activeProjects: Int
    public let projectsAtRisk: Int
    public let openTasks: Int
    public let openAssignedToMe: Int
    public let completedThisWeek: Int
    public let overdue: Int
    public let upcoming: [TaskItem]
    public let overdueMine: [TaskItem]
    public let completedMine: [TaskItem]
    public let deadlines: [DeadlineBucket]

    public init(projects: [Project], tasks: [TaskItem], now: Date, calendar: Calendar) {
        let liveProjects = projects.filter { !$0.isArchived }
        let active = liveProjects.filter { $0.status != .complete }
        let visible = tasks.filter { $0.project?.isArchived != true }
        let open = visible.filter { $0.status != .done }
        let mine = visible.filter { $0.assignee?.isMe == true }
        let isOverdue: (TaskItem) -> Bool = { $0.isOverdue(now: now, calendar: calendar) }

        activeProjects = active.count
        projectsAtRisk = active.filter { $0.status == .risk }.count
        openTasks = open.count
        openAssignedToMe = open.filter { $0.assignee?.isMe == true }.count
        completedThisWeek =
            visible.filter { task in
                guard task.status == .done, let completed = task.completedAt else { return false }
                return now.timeIntervalSince(completed) < 7 * 24 * 3600
            }.count
        overdue = visible.filter(isOverdue).count
        upcoming =
            mine
            .filter { $0.status != .done && !isOverdue($0) }
            .sorted { lhs, rhs in
                switch (lhs.due, rhs.due) {
                case (let left?, let right?): left < right
                case (nil, _?): false
                case (_?, nil): true
                case (nil, nil): lhs.sortOrder < rhs.sortOrder
                }
            }
        overdueMine = mine.filter(isOverdue)
        completedMine =
            mine
            .filter { $0.status == .done }
            .sorted { $0.updatedAt > $1.updatedAt }
        deadlines = DeadlineBucket.make(from: open, now: now, calendar: calendar)
    }
}
