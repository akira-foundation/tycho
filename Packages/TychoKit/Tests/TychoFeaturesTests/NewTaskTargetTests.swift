import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct NewTaskTargetTests {
    @Test func prefersTheOpenProjectThenTheFirstLiveOne() {
        let archived = Project(key: "OLD", name: "Old")
        archived.isArchived = true
        archived.sortOrder = 1
        let first = Project(key: "AA", name: "A")
        first.sortOrder = 2
        let second = Project(key: "BB", name: "B")
        second.sortOrder = 3
        let all = [second, archived, first]

        #expect(NewTaskTarget.project(current: second.id, projects: all) === second)
        #expect(NewTaskTarget.project(current: nil, projects: all) === first)
        #expect(NewTaskTarget.project(current: UUID(), projects: all) === first)
        #expect(NewTaskTarget.project(current: nil, projects: [archived]) == nil)
    }
}
