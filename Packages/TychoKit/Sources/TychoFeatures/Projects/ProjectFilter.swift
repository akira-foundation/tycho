import Foundation
import TychoCore

struct ProjectFilter: Equatable {
    var query = ""
    var status: ProjectStatus?

    var isActive: Bool { !trimmedQuery.isEmpty || status != nil }

    private var trimmedQuery: String { query.trimmingCharacters(in: .whitespacesAndNewlines) }

    func apply(_ projects: [Project]) -> [Project] {
        projects.filter { matchesStatus($0) && matchesQuery($0) }
    }

    private func matchesStatus(_ project: Project) -> Bool {
        guard let status else { return true }
        return project.status == status
    }

    private func matchesQuery(_ project: Project) -> Bool {
        guard !trimmedQuery.isEmpty else { return true }
        return project.name.localizedStandardContains(trimmedQuery)
            || project.summary.localizedStandardContains(trimmedQuery)
    }
}
