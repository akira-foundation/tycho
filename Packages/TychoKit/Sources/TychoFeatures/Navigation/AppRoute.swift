import Foundation

public enum ProjectTab: String, CaseIterable, Hashable, Sendable {
    case board
    case list
    case table
    case calendar
    case timeline
    case files

    public var title: String {
        switch self {
        case .board: "Board"
        case .list: "List"
        case .table: "Table"
        case .calendar: "Calendar"
        case .timeline: "Timeline"
        case .files: "Files"
        }
    }
}

public enum AppRoute: Hashable, Sendable {
    case home
    case myTasks
    case tasks
    case calendar
    case timeline
    case projects
    case project(UUID, ProjectTab)
}

public enum SidebarItem: Hashable, Sendable {
    case home
    case myTasks
    case tasks
    case calendar
    case timeline
    case projects
    case project(UUID)
}
