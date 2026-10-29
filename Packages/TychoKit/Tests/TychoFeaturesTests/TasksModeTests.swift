import Testing

@testable import TychoFeatures

struct TasksModeTests {
    @Test func modesFollowTheOriginal() {
        #expect(TasksMode.allCases.map(\.title) == ["List", "Board", "Table"])
        #expect(TasksMode.list.rawValue == "list")
    }

    @Test func subtitleCountsTheProjects() {
        #expect(TasksMode.subtitle(projectCount: 7) == "Every task across 7 projects.")
    }
}
