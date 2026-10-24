import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct RouterTests {
    @Test func startsAtHome() {
        let router = Router()
        #expect(router.route == .home)
        #expect(router.sidebarItem == .home)
    }

    @Test func sidebarSelectionOpensTheProjectOnItsLastTab() {
        let router = Router()
        let id = UUID()
        router.sidebarItem = .project(id)
        #expect(router.route == .project(id, .board))
        router.openProject(id, tab: .list)
        router.sidebarItem = .home
        router.sidebarItem = .project(id)
        #expect(router.route == .project(id, .list))
        #expect(router.currentProjectID == id)
    }

    @Test func inspectorAndCreationFlags() {
        let router = Router()
        let id = UUID()
        router.inspect(id)
        #expect(router.inspectedTaskID == id)
        router.closeInspector()
        #expect(router.inspectedTaskID == nil)
        router.newTask(status: .review)
        #expect(router.isCreatingTask)
        #expect(router.draftStatus == .review)
        router.newProject()
        #expect(router.isCreatingProject)
    }

    @Test func showsSettings() {
        let router = Router()
        router.showSettings()
        #expect(router.isShowingSettings)
    }

    @Test func workspaceRoutesMapToTheSidebar() {
        let router = Router()
        let pairs: [(SidebarItem, AppRoute)] = [(.tasks, .tasks), (.calendar, .calendar), (.timeline, .timeline)]
        for (item, route) in pairs {
            router.sidebarItem = item
            #expect(router.route == route)
            #expect(router.sidebarItem == item)
        }
    }

    @Test func newTaskCarriesAnOptionalDueDate() {
        let router = Router()
        let due = Date(timeIntervalSince1970: 1_800_000_000)
        router.newTask(due: due)
        #expect(router.draftDue == due)
        #expect(router.isCreatingTask)
        router.newTask()
        #expect(router.draftDue == nil)
    }

    @Test func scheduleStateStartsLikeTheOriginal() {
        let router = Router()
        #expect(router.calendarMode == .month)
        #expect(router.timelineZoom == .week)
        #expect(router.timelineGrouping == .status)
    }

    @Test func theWorkspaceTimelineStartsGroupedByProjectOnlyOnce() {
        let router = Router()
        router.openWorkspaceTimeline()
        #expect(router.timelineGrouping == .project)
        router.timelineGrouping = .assignee
        router.openWorkspaceTimeline()
        #expect(router.timelineGrouping == .assignee)
        #expect(router.hasOpenedWorkspaceTimeline)
    }
}
