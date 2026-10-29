import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TaskTableView: View {
    @Environment(Router.self) var router
    @Environment(ToastCenter.self) var toast
    @Query(sort: \Member.name) var members: [Member]
    @Query private var projects: [Project]
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif
    let tasks: [TaskItem]
    let model: TaskViewModel

    init(tasks: [TaskItem], model: TaskViewModel) {
        self.tasks = tasks
        self.model = model
    }

    var body: some View {
        let groups = model.groups(
            tasks, members: members, projects: projects, now: .now, calendar: DateText.gregorian)
        content(groups)
            .background(Token.bg.color)
            .onAppear(perform: prune)
    }

    @ViewBuilder private func content(_ groups: [TaskViewGroup]) -> some View {
        let visible = model.apply(tasks, now: .now, calendar: DateText.gregorian)
        switch (tasks.isEmpty, FilteredEmptyState.applies(source: tasks.count, visible: visible.count), isCompact) {
        case (true, _, _): empty
        case (false, true, _): FilteredEmptyState { model.clearFilters() }
        case (false, false, true): TableCardList(tasks: visible)
        case (false, false, false): grid(groups)
        }
    }

    private func prune() {
        let live = Set(projects.map(\.id))
        guard !live.isEmpty else { return }
        model.prune(liveProjectIDs: live)
    }

    private var sortBinding: Binding<[TaskComparator]> {
        Binding(get: { model.state.sort }, set: { model.setSort($0) })
    }

    private var customization: Binding<TableColumnCustomization<TaskItem>> {
        Binding(get: { model.columnCustomization }, set: { model.setColumnCustomization($0) })
    }

    private var isCompact: Bool {
        #if os(iOS)
        sizeClass == .compact
        #else
        false
        #endif
    }

    private func grid(_ groups: [TaskViewGroup]) -> some View {
        let grouping = model.state.grouping
        return VStack(spacing: 0) {
            Table(of: TaskItem.self, sortOrder: sortBinding, columnCustomization: customization) {
                columns
            } rows: {
                ForEach(groups) { group in
                    Section {
                        ForEach(group.tasks) { TableRow($0) }
                    } header: {
                        TableGroupHeader(
                            title: group.title, count: group.tasks.count,
                            status: grouping == .status ? TaskStatus(rawValue: group.id) : nil)
                    }
                }
            }
            .accessibilityIdentifier("table.grid")
            Divider()
            Button {
                router.newTask()
            } label: {
                Label("New task", systemImage: "plus")
                    .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(Token.text3.color)
            .padding(.horizontal, Spacing.s4)
            .accessibilityIdentifier("table.newTask")
        }
    }

    private var empty: some View {
        VStack(spacing: Spacing.s3) {
            EmptyState(title: "No tasks here", symbol: "tablecells", message: "Add a task to get things moving.")
            Button("Add task") { router.newTask() }
                .buttonStyle(.tycho(.primary))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
