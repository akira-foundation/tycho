import Foundation

public enum ProjectTab: String, CaseIterable, Hashable, Sendable {
    case list
    case board

    public var title: String {
        switch self {
        case .list: "List"
        case .board: "Board"
        }
    }
}

public enum AppRoute: Hashable, Sendable {
    case home
    case myTasks
    case projects
    case project(UUID, ProjectTab)
}

public enum SidebarItem: Hashable, Sendable {
    case home
    case myTasks
    case projects
    case project(UUID)
}
