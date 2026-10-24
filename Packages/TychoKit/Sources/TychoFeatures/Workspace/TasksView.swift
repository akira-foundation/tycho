import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

enum TasksMode: String, CaseIterable, Identifiable {
    case list
    case board
    case table

    var id: String { rawValue }

    var title: String {
        switch self {
        case .list: "List"
        case .board: "Board"
        case .table: "Table"
        }
    }

    var symbol: String {
        switch self {
        case .list: "list.bullet"
        case .board: "rectangle.split.3x1"
        case .table: "tablecells"
        }
    }

    static func subtitle(projectCount: Int) -> String { "Every task across \(projectCount) projects." }
}

struct TasksView: View {
    @Environment(Router.self) private var router
    @Query private var tasks: [TaskItem]
    @Query(filter: #Predicate<Project> { !$0.isArchived }) private var projects: [Project]
    @AppStorage("tasks.mode") private var mode = TasksMode.list

    var body: some View {
        let visible = tasks.inLiveProjects()
        VStack(spacing: 0) {
            PageHeader(title: "Tasks", subtitle: TasksMode.subtitle(projectCount: projects.count)) {
                TychoSegmented(selection: $mode, options: TasksMode.allCases) {
                    Label($0.title, systemImage: $0.symbol)
                }
                .accessibilityIdentifier("tasks.mode")
                Button("New task", systemImage: "plus") { router.newTask() }
                    .buttonStyle(.tycho(.primary))
            }
            Divider()
            switch mode {
            case .list:
                TaskListView(tasks: visible, project: nil)
            case .board:
                BoardView(tasks: visible, project: nil)
            case .table:
                TaskTableView(tasks: visible, project: nil, stateKey: TableViewStates.workspaceKey)
            }
        }
        .background(Token.bg.color)
        .navigationTitle("Tasks")
    }
}
