import Foundation
import SwiftData

public struct ProjectDraft {
    public var name: String
    public var key: String
    public var symbol: String = "folder"
    public var color: ProjectColor = .indigo
    public var status: ProjectStatus = .planning
    public var start: Date?
    public var due: Date?
    public var summary: String = ""
    public var lead: Member?

    public init(name: String, key: String) {
        self.name = name
        self.key = key
    }

    public init(project: Project) {
        name = project.name
        key = project.key
        symbol = project.symbol
        color = project.color
        status = project.status
        start = project.start
        due = project.due
        summary = project.summary
        lead = project.lead
    }
}

@MainActor
public struct ProjectActions {
    private let context: ModelContext
    private let now: () -> Date

    public init(context: ModelContext, now: @escaping () -> Date = { .now }) {
        self.context = context
        self.now = now
    }

    public static func normalizedKey(_ raw: String) -> String {
        raw.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    @discardableResult
    public func create(_ draft: ProjectDraft, in workspace: Workspace) throws -> Project {
        let (name, key) = try validate(draft, in: workspace, excluding: nil)
        let project = Project(key: key, name: name)
        project.sortOrder = Rank.appendOrder(after: workspace.projects ?? [])
        project.createdAt = now()
        context.insert(project)
        project.workspace = workspace
        apply(draft, name: name, key: key, to: project)
        if let lead = draft.lead {
            project.members = [lead]
        }
        try context.saveOrRollback()
        return project
    }

    public func update(_ project: Project, with draft: ProjectDraft) throws {
        let (name, key) = try validate(draft, in: project.workspace, excluding: project)
        apply(draft, name: name, key: key, to: project)
        try context.saveOrRollback()
    }

    public func toggleFavorite(_ project: Project) throws {
        project.isFavorite.toggle()
        project.updatedAt = now()
        try context.saveOrRollback()
    }

    public func move(_ project: Project, to index: Int, among siblings: [Project]) throws {
        Rank.insert(project, into: siblings, at: index)
        try context.saveOrRollback()
    }

    public func delete(_ project: Project) throws {
        context.delete(project)
        try context.saveOrRollback()
    }

    private func validate(
        _ draft: ProjectDraft,
        in workspace: Workspace?,
        excluding current: Project?
    ) throws -> (String, String) {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { throw ValidationError.emptyName }
        let rawKey = draft.key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (2...5).contains(rawKey.count), rawKey.allSatisfy({ $0.isASCII && $0.isLetter }) else {
            throw ValidationError.invalidProjectKey
        }
        let key = Self.normalizedKey(rawKey)
        let taken = (workspace?.projects ?? []).contains { $0 !== current && $0.key == key }
        guard !taken else { throw ValidationError.duplicateProjectKey }
        return (name, key)
    }

    private func apply(_ draft: ProjectDraft, name: String, key: String, to project: Project) {
        project.name = name
        project.key = key
        project.symbol = draft.symbol
        project.color = draft.color
        project.status = draft.status
        project.start = draft.start
        project.due = draft.due
        project.summary = draft.summary
        project.lead = draft.lead
        project.updatedAt = now()
    }
}
