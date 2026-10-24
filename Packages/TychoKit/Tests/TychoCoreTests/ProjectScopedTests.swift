import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct ProjectScopedTests {
    @Test func onlyItemsOfLiveProjectsRemain() throws {
        let context = try makeTestContext()
        let live = Project(key: "WEB", name: "Website")
        let archived = Project(key: "OLD", name: "Old")
        archived.isArchived = true
        context.insert(live)
        context.insert(archived)
        let kept = TaskItem(number: 1, title: "Kept")
        let hidden = TaskItem(number: 2, title: "Hidden")
        let orphan = TaskItem(number: 3, title: "Orphan")
        for task in [kept, hidden, orphan] { context.insert(task) }
        kept.project = live
        hidden.project = archived
        let milestone = Milestone(name: "Launch", date: nil)
        context.insert(milestone)
        milestone.project = archived

        #expect([kept, hidden, orphan].inLiveProjects().map(\.title) == ["Kept"])
        #expect([milestone].inLiveProjects().isEmpty)
    }
}
