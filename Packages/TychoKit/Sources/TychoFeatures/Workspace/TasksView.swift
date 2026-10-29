import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TasksView: View {
    @Environment(Router.self) private var router
    @Query private var tasks: [TaskItem]
    @Query(sort: \Member.name) private var members: [Member]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @State private var model: TaskViewModel

    init() {
        TasksMode.migrateLegacyPreference(.standard)
        _model = State(initialValue: TaskViewModel(key: TaskViewStates.tasksKey, inProject: false))
    }

    var body: some View {
        let source = tasks.inLiveProjects()
        let mode = TasksMode(state: model.state)
        VStack(spacing: 0) {
            PageHeader(title: "Tasks", subtitle: TasksMode.subtitle(projectCount: projects.count)) {}
            Divider()
            TaskViewHeader(
                engine: TaskViewEngine(model: model, members: members, projects: projects),
                showsGroup: mode != .board, showsColumns: mode == .table
            ) { extras(mode) }
            switch mode {
            case .list:
                list(source)
            case .board:
                BoardView(tasks: visible(source), project: nil)
            case .table:
                TaskTableView(tasks: source, model: model)
            }
        }
        .background(Token.bg.color)
        .tracksLiveProjects(model)
        .navigationTitle("Tasks")
    }

    @ViewBuilder private func extras(_ mode: TasksMode) -> some View {
        Picker("View", selection: Binding(get: { mode }, set: { model.state.mode = $0.rawValue })) {
            ForEach(TasksMode.allCases) { Label($0.title, systemImage: $0.symbol).tag($0) }
        }
        .pickerStyle(.segmented)
        .labelsHidden()
        .fixedSize()
        .accessibilityIdentifier("tasks.mode")
        Button("New task", systemImage: "plus") { router.newTask() }
            .buttonStyle(.tycho(.primary))
    }

    private func visible(_ source: [TaskItem]) -> [TaskItem] {
        model.apply(source, now: .now, calendar: DateText.gregorian)
    }

    @ViewBuilder private func list(_ source: [TaskItem]) -> some View {
        let shown = visible(source)
        let state = model.state
        if FilteredEmptyState.applies(source: source.count, visible: shown.count) {
            FilteredEmptyState { model.clearFilters() }
        } else {
            TaskListView(
                groups: model.groups(
                    of: shown, members: members, projects: projects, now: .now, calendar: DateText.gregorian),
                grouping: state.grouping, project: nil,
                allowsReorder: ListDropPolicy.allowsReorder(sort: state.sort, grouping: state.grouping))
        }
    }
}
