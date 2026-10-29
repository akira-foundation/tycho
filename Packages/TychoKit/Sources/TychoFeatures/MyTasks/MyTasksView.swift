import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct MyTasksView: View {
    @Query private var tasks: [TaskItem]
    @Query(sort: \Member.name) private var members: [Member]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @State private var model = TaskViewModel(key: TaskViewStates.myTasksKey, inProject: false)

    var body: some View {
        let mine = tasks.inLiveProjects().filter { $0.assignee?.isMe == true }
        VStack(spacing: 0) {
            TaskViewHeader(engine: TaskViewEngine(model: model, members: members, projects: projects))
            content(mine)
        }
        .background(Token.bg.color)
        .tracksLiveProjects(model)
        .navigationTitle("My Tasks")
    }

    @ViewBuilder private func content(_ mine: [TaskItem]) -> some View {
        let now = Date.now
        let shown = MyTaskGroups.query(for: model.state).apply(mine, now: now, calendar: DateText.gregorian)
        switch (mine.isEmpty, FilteredEmptyState.applies(source: mine.count, visible: shown.count)) {
        case (true, _):
            EmptyState(
                title: "Nothing assigned to you", symbol: "checklist",
                message: "Tasks assigned to you show up here.")
        case (false, true):
            FilteredEmptyState { model.clearFilters() }
        case (false, false):
            TaskListView(
                groups: MyTaskGroups.groups(shown, now: now, calendar: DateText.gregorian),
                grouping: .none, project: nil, allowsReorder: false,
                initiallyCollapsed: MyTaskGroups.initiallyCollapsed)
        }
    }
}
