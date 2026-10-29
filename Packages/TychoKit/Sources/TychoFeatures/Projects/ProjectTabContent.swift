import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct ProjectTabContent: View {
    @Query(sort: \Member.name) private var members: [Member]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @State private var model: TaskViewModel
    let project: Project
    let tab: ProjectTab

    init(project: Project, tab: ProjectTab) {
        self.project = project
        self.tab = tab
        _model = State(initialValue: TaskViewModel.project(project.id))
    }

    var body: some View {
        let source = project.tasks ?? []
        let engine = TaskViewEngine(model: model, members: members, projects: projects)
        switch tab.builtIn ?? .board {
        case .board:
            VStack(spacing: 0) {
                TaskViewHeader(engine: engine)
                BoardView(tasks: visible(source), project: project)
            }
        case .list:
            VStack(spacing: 0) {
                TaskViewHeader(engine: engine, showsGroup: true)
                list(source)
            }
        case .table:
            VStack(spacing: 0) {
                TaskViewHeader(engine: engine, showsGroup: true, showsColumns: true)
                TaskTableView(tasks: source, model: model)
            }
        case .calendar:
            CalendarView(tasks: visible(source), events: project.events ?? [], project: project, engine: engine)
        case .timeline:
            TimelineView(
                tasks: visible(source), milestones: project.milestones ?? [], project: project, engine: engine)
        case .files:
            FilesView(project: project)
        }
    }

    private func visible(_ source: [TaskItem]) -> [TaskItem] {
        model.apply(source, now: .now, calendar: DateText.gregorian)
    }

    @ViewBuilder private func list(_ source: [TaskItem]) -> some View {
        let groups = model.groups(
            source, members: members, projects: projects, now: .now, calendar: DateText.gregorian)
        if FilteredEmptyState.applies(source: source.count, visible: visible(source).count) {
            FilteredEmptyState { model.clearFilters() }
        } else {
            TaskListView(groups: groups, grouping: model.state.grouping, project: project)
        }
    }
}
