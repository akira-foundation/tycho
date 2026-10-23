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
}
