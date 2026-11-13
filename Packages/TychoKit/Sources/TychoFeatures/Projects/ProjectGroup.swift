import Foundation
import TychoCore

struct ProjectGroup: Identifiable {
    let title: String
    let projects: [Project]

    var id: String { title }

    static func summary(_ projects: [Project], sort: ProjectSort) -> [ProjectGroup] {
        let favorites = projects.filter(\.isFavorite)
        let others = projects.filter { !$0.isFavorite }
        let favoriteGroup = [ProjectGroup(title: "Favorites", projects: sort.sorted(favorites))]
        let statusGroups = ProjectStatus.allCases.map { status in
            ProjectGroup(title: status.title, projects: sort.sorted(others.filter { $0.status == status }))
        }
        return (favoriteGroup + statusGroups).filter { !$0.projects.isEmpty }
    }

    static func subtitle(_ projects: [Project]) -> String {
        let completed = projects.filter { $0.status == .complete }.count
        return "\(projects.count - completed) active · \(completed) completed"
    }

    static func detailLine(for project: Project) -> String {
        let tasks = "\(project.doneTaskCount) of \(project.taskCount) tasks"
        guard let lead = project.lead else { return tasks }
        return "\(tasks) · \(lead.name)"
    }
}
