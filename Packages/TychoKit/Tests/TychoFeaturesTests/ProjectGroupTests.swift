import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct ProjectGroupTests {
    private func project(_ name: String, status: ProjectStatus, favorite: Bool = false) -> Project {
        let project = Project(key: "AA", name: name)
        project.status = status
        project.isFavorite = favorite
        return project
    }

    @Test func favoritesComeFirstAndLeaveTheirStatusGroup() {
        let risky = project("Launch", status: .risk, favorite: true)
        let other = project("Portal", status: .risk, favorite: false)
        let done = project("Site", status: .complete, favorite: false)
        let groups = ProjectGroup.summary([done, other, risky], sort: .name)
        #expect(groups.map(\.title) == ["Favorites", "At Risk", "Completed"])
        #expect(groups.map { $0.projects.map(\.name) } == [["Launch"], ["Portal"], ["Site"]])
    }

    @Test func groupsFollowTheChosenSort() {
        let b = project("Beta", status: .active)
        let a = project("alpha", status: .active)
        #expect(ProjectGroup.summary([b, a], sort: .name).first?.projects.map(\.name) == ["alpha", "Beta"])
    }

    @Test func noProjectsMeansNoGroups() {
        #expect(ProjectGroup.summary([], sort: .recent).isEmpty)
    }

    @Test func subtitleCountsActiveAndCompleted() {
        let all = [
            project("A", status: .planning), project("B", status: .hold), project("C", status: .complete),
        ]
        #expect(ProjectGroup.subtitle(all) == "2 active · 1 completed")
    }

    @Test func detailLineOmitsAMissingLead() {
        let lone = project("A", status: .active)
        #expect(ProjectGroup.detailLine(for: lone) == "0 of 0 tasks")
        lone.lead = Member(name: "Sarah Chen", email: "sarah@example.com")
        #expect(ProjectGroup.detailLine(for: lone) == "0 of 0 tasks · Sarah Chen")
    }

    @Test func detailLineShowsDoneOutOfTotalTasksWithTheLead() {
        let project = project("A", status: .active)
        project.lead = Member(name: "Sarah Chen", email: "sarah@example.com")
        let tasks = (0..<5).map { TaskItem(number: $0, title: "T\($0)") }
        for task in tasks { task.project = project }
        for task in tasks.prefix(2) { task.status = .done }
        #expect(ProjectGroup.detailLine(for: project) == "2 of 5 tasks · Sarah Chen")
    }
}
