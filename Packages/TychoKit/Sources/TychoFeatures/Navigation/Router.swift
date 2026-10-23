import Foundation
import Observation
import SwiftUI
import TychoCore

@Observable
@MainActor
public final class Router {
    public var route: AppRoute = .home
    public var inspectedTaskID: UUID?
    public var isCreatingTask = false
    public var isCreatingProject = false
    public var draftStatus: TaskStatus = .todo
    public var columnVisibility: NavigationSplitViewVisibility = .automatic
    private var projectTabs: [UUID: ProjectTab] = [:]

    public init() {}

    public var sidebarItem: SidebarItem? {
        get {
            switch route {
            case .home: .home
            case .myTasks: .myTasks
            case .projects: .projects
            case .project(let id, _): .project(id)
            }
        }
        set {
            switch newValue {
            case .home?: route = .home
            case .myTasks?: route = .myTasks
            case .projects?: route = .projects
            case .project(let id)?: openProject(id, tab: projectTabs[id] ?? .board)
            case nil: break
            }
        }
    }

    public var currentProjectID: UUID? {
        if case .project(let id, _) = route { id } else { nil }
    }

    public func open(_ route: AppRoute) {
        if case .project(let id, let tab) = route {
            projectTabs[id] = tab
        }
        self.route = route
    }

    public func openProject(_ id: UUID, tab: ProjectTab) {
        open(.project(id, tab))
    }

    public func inspect(_ taskID: UUID) { inspectedTaskID = taskID }
    public func closeInspector() { inspectedTaskID = nil }

    public func newTask(status: TaskStatus = .todo) {
        draftStatus = status
        isCreatingTask = true
    }

    public func newProject() { isCreatingProject = true }
}

extension FocusedValues {
    @Entry public var router: Router?
}
