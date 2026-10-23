import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct ProjectActionsTests {
    private func setUp() throws -> (ModelContext, Workspace, ProjectActions) {
        let context = try makeTestContext()
        let workspace = Workspace(name: "Personal")
        context.insert(workspace)
        return (context, workspace, ProjectActions(context: context, now: { referenceNow }))
    }

    @Test func createsAProjectAtTheEndOfTheSidebar() throws {
        let (_, workspace, actions) = try setUp()
        let first = try actions.create(ProjectDraft(name: "Website", key: "WEB"), in: workspace)
        var draft = ProjectDraft(name: "Mobile App", key: " mob ")
        draft.color = .blue
        let second = try actions.create(draft, in: workspace)

        #expect(second.key == "MOB")
        #expect(second.color == .blue)
        #expect(second.workspace === workspace)
        #expect(second.sortOrder > first.sortOrder)
        #expect(second.createdAt == referenceNow)
        #expect(second.nextTaskNumber == 1)
    }

    @Test(arguments: ["", "   ", "\n"])
    func rejectsABlankName(name: String) throws {
        let (_, workspace, actions) = try setUp()
        #expect(throws: ValidationError.emptyName) {
            try actions.create(ProjectDraft(name: name, key: "WEB"), in: workspace)
        }
    }

    @Test(arguments: ["W", "WEBSITE", "W3B", "WÉB", "", "ß", "ﬁ"])
    func rejectsAnInvalidKey(key: String) throws {
        let (_, workspace, actions) = try setUp()
        #expect(throws: ValidationError.invalidProjectKey) {
            try actions.create(ProjectDraft(name: "Web", key: key), in: workspace)
        }
    }

    @Test func rejectsADuplicateKeyRegardlessOfCase() throws {
        let (_, workspace, actions) = try setUp()
        try actions.create(ProjectDraft(name: "Website", key: "WEB"), in: workspace)
        #expect(throws: ValidationError.duplicateProjectKey) {
            try actions.create(ProjectDraft(name: "Web 2", key: "web"), in: workspace)
        }
    }

    @Test func updateKeepsItsOwnKeyAndBumpsUpdatedAt() throws {
        let (context, workspace, _) = try setUp()
        var clock = referenceNow
        let actions = ProjectActions(context: context, now: { clock })
        let project = try actions.create(ProjectDraft(name: "Website", key: "WEB"), in: workspace)
        clock = referenceNow.addingTimeInterval(60)
        var draft = ProjectDraft(name: "Website Redesign", key: "WEB")
        draft.status = .risk
        try actions.update(project, with: draft)

        #expect(project.name == "Website Redesign")
        #expect(project.status == .risk)
        #expect(project.updatedAt == clock)
    }

    @Test func movesAProjectBetweenSiblings() throws {
        let (_, workspace, actions) = try setUp()
        let a = try actions.create(ProjectDraft(name: "A", key: "AA"), in: workspace)
        let b = try actions.create(ProjectDraft(name: "B", key: "BB"), in: workspace)
        let c = try actions.create(ProjectDraft(name: "C", key: "CC"), in: workspace)
        try actions.move(c, to: 0, among: [a, b])
        let ordered = (workspace.projects ?? []).sorted { $0.sortOrder < $1.sortOrder }
        #expect(ordered.map(\.key) == ["CC", "AA", "BB"])
    }

    @Test func togglesFavoriteAndDeletes() throws {
        let (context, workspace, actions) = try setUp()
        let project = try actions.create(ProjectDraft(name: "Website", key: "WEB"), in: workspace)
        try actions.toggleFavorite(project)
        #expect(project.isFavorite)
        try actions.delete(project)
        #expect(try context.fetchCount(FetchDescriptor<Project>()) == 0)
    }
}
