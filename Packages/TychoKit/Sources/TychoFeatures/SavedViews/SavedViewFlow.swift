import Foundation
import SwiftData
import TychoCore

@MainActor
struct SavedViewFlow {
    let context: ModelContext
    let router: Router
    let toast: ToastCenter
    var defaults: UserDefaults = TychoDefaults.current

    func baseFilters(of project: Project) -> [TaskFilter] {
        let data = defaults.data(forKey: TaskViewStates.storageKey) ?? Data()
        return TaskViewStates.state(for: TaskViewStates.projectKey(project.id), inProject: true, in: data).filters
    }

    func save(name: String, layout: SavedViewLayout, in project: Project) {
        toast.perform {
            let view = try SavedViewActions(context: context).create(
                name: name, layout: layout, filters: baseFilters(of: project), in: project)
            router.openProject(project.id, tab: .savedView(view.id))
            toast.show("Saved view “\(view.name)”")
        }
    }

    func rename(_ view: SavedView, to name: String) {
        toast.perform { try SavedViewActions(context: context).rename(view, to: name) }
    }

    func delete(_ view: SavedView) {
        let name = view.name
        let tab = ProjectTab.savedView(view.id)
        let projectID = view.project?.id
        toast.perform {
            try SavedViewActions(context: context).delete(view)
            if let projectID, router.route == .project(projectID, tab) {
                router.openProject(projectID, tab: .list)
            }
            toast.show("Deleted view “\(name)”")
        }
    }
}

extension TaskViewModel {
    static func savedView(_ id: UUID, defaults: UserDefaults = TychoDefaults.current) -> TaskViewModel {
        TaskViewModel(key: TaskViewStates.savedViewKey(id), inProject: true, defaults: defaults)
    }
}
