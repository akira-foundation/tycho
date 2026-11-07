import Foundation
import TychoCore

struct FilterOption: Identifiable, Hashable {
    let id: String
    let title: String
}

enum FilterOptions {
    static func options(for field: TaskFilterField, members: [Member], projects: [Project]) -> [FilterOption] {
        switch field {
        case .status: TaskStatus.allCases.map { FilterOption(id: $0.rawValue, title: $0.title) }
        case .priority: TaskPriority.allCases.map { FilterOption(id: $0.rawValue, title: $0.title) }
        case .labels: TaskLabel.allCases.map { FilterOption(id: $0.rawValue, title: $0.title) }
        case .due: DueBucket.allCases.map { FilterOption(id: $0.rawValue, title: $0.title) }
        case .created, .updated: RecencyWindow.allCases.map { FilterOption(id: String($0.rawValue), title: $0.title) }
        case .assignee: assigneeOptions(members)
        case .project: projectOptions(projects)
        }
    }

    static func listsValuesInMenu(_ field: TaskFilterField) -> Bool {
        switch field {
        case .status, .assignee, .priority, .project, .labels: true
        case .due, .created, .updated: false
        }
    }

    static func summary(_ filter: TaskFilter, options: [FilterOption]) -> String {
        let noun = noun(for: filter.field)
        guard let first = filter.values.first else { return "Any \(noun.singular)" }
        let count = filter.values.count
        if count == 1, let title = options.first(where: { $0.id == first })?.title {
            return title
        }
        return "\(count) \(count == 1 ? noun.singular : noun.plural)"
    }

    private static func noun(for field: TaskFilterField) -> (singular: String, plural: String) {
        switch field {
        case .status: ("status", "statuses")
        case .assignee: ("assignee", "assignees")
        case .priority: ("priority", "priorities")
        case .due: ("due date", "due dates")
        case .project: ("project", "projects")
        case .labels: ("label", "labels")
        case .created: ("created date", "created dates")
        case .updated: ("updated date", "updated dates")
        }
    }

    private static func assigneeOptions(_ members: [Member]) -> [FilterOption] {
        let named = members.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map { FilterOption(id: $0.id.uuidString, title: $0.isMe ? "\($0.name) (you)" : $0.name) }
        return [FilterOption(id: TaskFilter.noAssignee, title: "Unassigned")] + named
    }

    private static func projectOptions(_ projects: [Project]) -> [FilterOption] {
        projects.filter { !$0.isArchived }
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { FilterOption(id: $0.id.uuidString, title: $0.name) }
    }
}
