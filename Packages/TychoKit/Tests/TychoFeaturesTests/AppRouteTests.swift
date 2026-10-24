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
        #expect(ProjectTab.allCases.map(\.title) == ["Board", "List", "Table", "Calendar", "Timeline", "Files"])
    }
}
