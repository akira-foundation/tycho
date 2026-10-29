import Foundation

public enum ProjectBuiltInTab: String, CaseIterable, Hashable, Sendable {
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

public enum ProjectTab: Hashable, Sendable {
    case builtIn(ProjectBuiltInTab)
    case savedView(UUID)

    public static let board = ProjectTab.builtIn(.board)
    public static let list = ProjectTab.builtIn(.list)
    public static let table = ProjectTab.builtIn(.table)
    public static let calendar = ProjectTab.builtIn(.calendar)
    public static let timeline = ProjectTab.builtIn(.timeline)
    public static let files = ProjectTab.builtIn(.files)

    public var builtIn: ProjectBuiltInTab? {
        guard case .builtIn(let tab) = self else { return nil }
        return tab
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
    case search
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
