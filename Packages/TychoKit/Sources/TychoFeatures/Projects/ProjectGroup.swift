import Foundation
import TychoCore

struct ProjectGroup: Identifiable {
    let title: String
    let projects: [Project]

    var id: String { title }

    static func summary(_ projects: [Project], sort: ProjectSort) -> [ProjectGroup] {
        let sorted = sort.sorted(projects)
        let others = sorted.filter { !$0.isFavorite }
        return [
            ProjectGroup(title: "Favorites", projects: sorted.filter(\.isFavorite)),
            ProjectGroup(title: "Active", projects: others.filter { $0.status != .complete }),
            ProjectGroup(title: "Completed", projects: others.filter { $0.status == .complete }),
        ]
        .filter { !$0.projects.isEmpty }
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
