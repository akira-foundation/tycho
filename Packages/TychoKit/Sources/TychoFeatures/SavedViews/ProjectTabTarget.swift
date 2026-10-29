import Foundation
import TychoCore

struct ProjectTabTarget {
    let layout: ProjectBuiltInTab
    let savedView: SavedView?
    let stateKey: String
    let title: String

    @MainActor
    init(tab: ProjectTab, in project: Project) {
        let view: SavedView? =
            switch tab {
            case .builtIn: nil
            case .savedView(let id): SavedView.ordered(in: project).first { $0.id == id }
            }
        savedView = view
        layout = view.map { Self.layout(for: $0.layout) } ?? tab.builtIn ?? .board
        stateKey = view.map { TaskViewStates.savedViewKey($0.id) } ?? TaskViewStates.projectKey(project.id)
        title = view == nil ? project.name : "Saved view · \(project.name)"
    }

    private static func layout(for layout: SavedViewLayout) -> ProjectBuiltInTab {
        switch layout {
        case .list: .list
        case .board: .board
        case .table: .table
        }
    }
}
