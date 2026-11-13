import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct MyTasksView: View {
    @Environment(\.isCompactWidth) private var isCompactWidth
    @Query private var tasks: [TaskItem]
    @Query(sort: \Member.name) private var members: [Member]
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]
    @State private var model = TaskViewModel(key: TaskViewStates.myTasksKey, inProject: false)

    var body: some View {
        let mine = tasks.inLiveProjects().filter { $0.assignee?.isMe == true }
        let mode = MyTasksMode(state: model.state)
        content(mine, mode: mode)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .taskViewControls(
                TaskViewEngine(model: model, members: members, projects: projects),
                showsGroup: mode == .table, showsColumns: mode == .table
            ) {
                if isCompactWidth {
                    modePicker(mode).pickerStyle(.menu)
                }
                if mode == .board {
                    BoardColumnsMenu(model: model)
                }
                if mode == .calendar {
                    CalendarModePicker().pickerStyle(.menu)
                }
            }
            .toolbar {
                if !isCompactWidth {
                    ToolbarItem { modePicker(mode).segmentedToolbar() }
                }
            }
            .tracksLiveProjects(model)
            .navigationTitle("My Tasks")
    }

    private func modePicker(_ mode: MyTasksMode) -> TaskModePicker<MyTasksMode> {
        TaskModePicker(model: model, mode: mode, identifier: "mytasks.mode")
    }

    @ViewBuilder private func content(_ mine: [TaskItem], mode: MyTasksMode) -> some View {
        let now = Date.now
        let shown = MyTaskGroups.query(for: model.state).apply(mine, now: now, calendar: DateText.gregorian)
        switch (mine.isEmpty, mode) {
        case (true, _):
            EmptyState(
                title: "Nothing assigned to you", symbol: "checklist",
                message: "Tasks assigned to you show up here.")
        case (false, .list):
            list(shown, source: mine, now: now)
        case (false, .board):
            BoardView(tasks: shown, project: nil, hiddenStatuses: model.state.hiddenStatuses)
        case (false, .table):
            TaskTableView(tasks: mine, model: model)
        case (false, .calendar):
            CalendarView(tasks: shown, events: [])
        }
    }

    @ViewBuilder private func list(_ shown: [TaskItem], source: [TaskItem], now: Date) -> some View {
        if FilteredEmptyState.applies(source: source.count, visible: shown.count) {
            FilteredEmptyState { model.clearFilters() }
        } else {
            TaskListView(
                groups: MyTaskGroups.groups(shown, now: now, calendar: DateText.gregorian),
                grouping: .none, project: nil, allowsReorder: false,
                initiallyCollapsed: MyTaskGroups.initiallyCollapsed)
        }
    }
}
