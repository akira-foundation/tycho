import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TasksView: View {
    @Environment(Router.self) private var router
    @Environment(\.isCompactWidth) private var isCompactWidth
    @Query private var tasks: [TaskItem]
    @Query(sort: \Member.name) private var members: [Member]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @State private var model: TaskViewModel

    init() {
        TasksMode.migrateLegacyPreference(TychoDefaults.current)
        _model = State(initialValue: TaskViewModel(key: TaskViewStates.tasksKey, inProject: false))
    }

    var body: some View {
        let source = tasks.inLiveProjects()
        let mode = TasksMode.current(in: model)
        VStack(spacing: 0) {
            switch mode {
            case .list:
                list(source)
            case .board:
                BoardView(tasks: visible(source), project: nil)
            case .table:
                TaskTableView(tasks: source, model: model)
            }
        }
        .taskViewControls(
            TaskViewEngine(model: model, members: members, projects: projects),
            showsGroup: mode != .board, showsColumns: mode == .table
        ) {
            if isCompactWidth {
                modePicker(mode).pickerStyle(.menu)
            }
        }
        .toolbar {
            if !isCompactWidth {
                ToolbarItem { modePicker(mode).pickerStyle(.segmented).segmentedToolbarWidth(TasksMode.allCases.count) }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("New Task", systemImage: "plus") { router.newTask() }
            }
        }
        .tracksLiveProjects(model)
        .navigationTitle(TasksMode.title(filters: model.state.filters))
        .navigationSubtitle(TasksMode.subtitle(projectCount: projects.count, filters: model.state.filters))
    }

    private func modePicker(_ mode: TasksMode) -> some View {
        Picker(selection: Binding(get: { mode }, set: { model.state.mode = $0.rawValue })) {
            ForEach(TasksMode.allCases) { SegmentLabel(title: $0.title, symbol: $0.symbol).tag($0) }
        } label: {
            Label("View", systemImage: mode.symbol)
        }
        .accessibilityIdentifier("tasks.mode")
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

extension View {
    @ViewBuilder fileprivate func segmentedToolbarWidth(_ segments: Int) -> some View {
        #if os(iOS)
        self.frame(width: CGFloat(segments) * 44)
        #else
        self
        #endif
    }
}
