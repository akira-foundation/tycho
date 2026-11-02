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

    static func summary(_ filter: TaskFilter, options: [FilterOption]) -> String {
        guard !filter.values.isEmpty else { return "any" }
        let countText = "\(filter.values.count) selected"
        guard filter.values.count <= 2 else { return countText }
        let titles = filter.values.compactMap { value in options.first { $0.id == value }?.title }
        return titles.isEmpty ? countText : titles.joined(separator: ", ")
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
