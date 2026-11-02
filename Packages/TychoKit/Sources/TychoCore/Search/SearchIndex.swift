import Foundation
import SwiftData

public enum SearchScope: String, CaseIterable, Sendable {
    case all
    case tasks
    case projects
    case files

    public var title: String {
        switch self {
        case .all: "All"
        case .tasks: "Tasks"
        case .projects: "Projects"
        case .files: "Files"
        }
    }

    public var symbol: String {
        switch self {
        case .all: "square.stack.3d.up"
        case .tasks: "checkmark.circle"
        case .projects: "folder"
        case .files: "paperclip"
        }
    }
}

public struct SearchResults {
    public var tasks: [TaskItem] = []
    public var projects: [Project] = []
    public var files: [FileRecord] = []

    public var isEmpty: Bool { tasks.isEmpty && projects.isEmpty && files.isEmpty }

    public init(tasks: [TaskItem] = [], projects: [Project] = [], files: [FileRecord] = []) {
        self.tasks = tasks
        self.projects = projects
        self.files = files
    }
}

@MainActor
public enum SearchIndex {
    public static let taskCap = 30

    public static func search(_ query: String, in context: ModelContext, limit: Int? = nil) throws -> SearchResults {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return SearchResults() }
        let cap = limit ?? .max

        let projects = try context.fetch(FetchDescriptor<Project>(sortBy: [SortDescriptor(\.sortOrder)]))
            .filter { !$0.isArchived }

        return SearchResults(
            tasks: Array(matchingTasks(needle, in: projects).prefix(min(cap, taskCap))),
            projects: Array(projects.filter { matches(needle, $0.name, $0.summary) }.prefix(cap)),
            files: Array(matchingFiles(needle, in: projects).prefix(cap))
        )
    }

    private static func matchingTasks(_ needle: String, in projects: [Project]) -> [TaskItem] {
        projects.flatMap { project in
            (project.tasks ?? [])
                .sorted { ($0.sortOrder, $0.number) < ($1.sortOrder, $1.number) }
                .filter { matches(needle, $0.title, $0.key, $0.notes) }
        }
    }

    private static func matchingFiles(_ needle: String, in projects: [Project]) -> [FileRecord] {
        projects.flatMap { project in
            (project.files ?? [])
                .filter { matches(needle, $0.name) }
                .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        }
    }

    private static func matches(_ needle: String, _ fields: String...) -> Bool {
        fields.contains { $0.localizedCaseInsensitiveContains(needle) }
    }
}
