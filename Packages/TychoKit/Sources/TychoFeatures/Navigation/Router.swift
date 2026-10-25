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
    public var isShowingSettings = false
    public var draftStatus: TaskStatus = .todo
    public var draftDue: Date?
    public var calendarDate: Date = .now
    public var calendarMode: CalendarMode = .month
    public var timelineZoom: TimelineZoom = .week
    public var timelineGrouping: TimelineGrouping = .status
    public private(set) var hasOpenedWorkspaceTimeline = false
    public var columnVisibility: NavigationSplitViewVisibility = .automatic
    public private(set) var inspectsInSheet = false
    private var projectTabs: [UUID: ProjectTab] = [:]

    public init() {}

    public var sidebarItem: SidebarItem? {
        get {
            switch route {
            case .home: .home
            case .myTasks: .myTasks
            case .tasks: .tasks
            case .calendar: .calendar
            case .timeline: .timeline
            case .projects: .projects
            case .project(let id, _): .project(id)
            }
        }
        set {
            switch newValue {
            case .home?: route = .home
            case .myTasks?: route = .myTasks
            case .tasks?: route = .tasks
            case .calendar?: route = .calendar
            case .timeline?: route = .timeline
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

    public func updateWindowWidth(_ width: CGFloat) {
        let inSheet = InspectorLayout.presentsAsSheet(windowWidth: width)
        guard inSheet != inspectsInSheet else { return }
        inspectsInSheet = inSheet
    }

    public var isInspectorSheetPresented: Bool { inspectedTaskID != nil && inspectsInSheet }

    public var isInspectorColumnPresented: Bool { inspectedTaskID != nil && !inspectsInSheet }

    public func inspect(_ taskID: UUID) { inspectedTaskID = taskID }
    public func closeInspector() { inspectedTaskID = nil }

    public func newTask(status: TaskStatus = .todo, due: Date? = nil) {
        draftStatus = status
        draftDue = due
        closeInspectorSheet()
        isCreatingTask = true
    }

    public func openWorkspaceTimeline() {
        guard !hasOpenedWorkspaceTimeline else { return }
        hasOpenedWorkspaceTimeline = true
        timelineGrouping = .project
    }

    public func newProject() {
        closeInspectorSheet()
        isCreatingProject = true
    }

    private func closeInspectorSheet() {
        if isInspectorSheetPresented { closeInspector() }
    }

    public func showSettings() { isShowingSettings = true }
}

extension FocusedValues {
    @Entry public var router: Router?
}
