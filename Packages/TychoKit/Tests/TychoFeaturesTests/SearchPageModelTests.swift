import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct SearchPageModelTests {
    private let results = SearchResults(
        tasks: [TaskItem(number: 1, title: "A"), TaskItem(number: 2, title: "B")],
        projects: [Project(key: "WEB", name: "Web")],
        files: []
    )

    @Test func countsPerScope() {
        let counts = SearchPageModel.counts(results)
        #expect(counts[.all] == 3)
        #expect(counts[.tasks] == 2)
        #expect(counts[.projects] == 1)
        #expect(counts[.files] == 0)
    }

    @Test func allScopeListsNonEmptySectionsInOrder() {
        let sections = SearchPageModel.sections(results, scope: .all)
        #expect(sections.map(\.title) == ["Tasks · 2", "Projects · 1"])
        #expect(sections.map(\.count) == [2, 1])
    }

    @Test func singleScopeListsOnlyThatSection() {
        #expect(SearchPageModel.sections(results, scope: .projects).map(\.title) == ["Projects · 1"])
        #expect(SearchPageModel.sections(results, scope: .files).isEmpty)
    }
}
