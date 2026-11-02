import Foundation
import Testing

@testable import TychoFeatures

struct AppRouteTests {
    @Test func projectRoutesCompareByIdAndTab() {
        let id = UUID()
        #expect(AppRoute.project(id, .board) == .project(id, .board))
        #expect(AppRoute.project(id, .board) != .project(id, .list))
    }

    @Test func projectTabsFollowTheOriginalOrder() {
        #expect(ProjectBuiltInTab.allCases.map(\.title) == ["Board", "List", "Table", "Calendar", "Timeline", "Files"])
    }

    @Test func savedViewTabsRoundTripThroughTheRoute() {
        let projectID = UUID()
        let viewID = UUID()
        let route = AppRoute.project(projectID, .savedView(viewID))
        guard case .project(let id, let tab) = route else {
            Issue.record("not a project route")
            return
        }
        #expect(id == projectID)
        #expect(tab == .savedView(viewID))
        #expect(tab.builtIn == nil)
        #expect(route != .project(projectID, .savedView(UUID())))
    }

    @Test func builtInConveniencesMatchTheEnum() {
        #expect(ProjectTab.board == .builtIn(.board))
        #expect(ProjectTab.list == .builtIn(.list))
        #expect(ProjectTab.table == .builtIn(.table))
        #expect(ProjectTab.calendar == .builtIn(.calendar))
        #expect(ProjectTab.timeline == .builtIn(.timeline))
        #expect(ProjectTab.files == .builtIn(.files))
        #expect(ProjectTab.files.builtIn == .files)
    }

    @MainActor @Test func searchRouteHasNoSidebarItem() {
        let router = Router()
        router.open(.search)
        #expect(router.route == .search)
        #expect(router.sidebarItem == nil)
    }
}
