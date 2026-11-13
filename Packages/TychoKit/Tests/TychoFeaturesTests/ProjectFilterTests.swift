import Foundation
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct ProjectFilterTests {
    private func project(_ name: String, summary: String = "", status: ProjectStatus = .active) -> Project {
        let project = Project(key: "AA", name: name)
        project.summary = summary
        project.status = status
        return project
    }

    @Test func anEmptyFilterKeepsEveryProjectAndIsInactive() {
        let projects = [project("Site"), project("App", status: .risk)]
        let filter = ProjectFilter(query: "  ")
        #expect(filter.apply(projects).map(\.name) == ["Site", "App"])
        #expect(!filter.isActive)
    }

    @Test func theQueryMatchesNameOrDescriptionIgnoringCase() {
        let projects = [
            project("Website Redesign"), project("Mobile App", summary: "Offline SYNC for field teams"),
            project("Portal"),
        ]
        #expect(ProjectFilter(query: "website").apply(projects).map(\.name) == ["Website Redesign"])
        #expect(ProjectFilter(query: "sync").apply(projects).map(\.name) == ["Mobile App"])
    }

    @Test func theStatusKeepsOnlyProjectsInThatStatus() {
        let projects = [project("Site", status: .risk), project("App"), project("Launch", status: .risk)]
        let filter = ProjectFilter(status: .risk)
        #expect(filter.apply(projects).map(\.name) == ["Site", "Launch"])
        #expect(filter.isActive)
    }

    @Test func queryAndStatusMustBothMatch() {
        let projects = [project("Site", status: .risk), project("Site Map")]
        #expect(ProjectFilter(query: "site", status: .active).apply(projects).map(\.name) == ["Site Map"])
    }
}
