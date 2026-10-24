import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TaskTableView: View {
    @Environment(Router.self) private var router
    @AppStorage(TableViewStates.storageKey) private var stored = Data()
    @Query(sort: \Member.name) var members: [Member]
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
    #endif
    let tasks: [TaskItem]
    let project: Project?
    let stateKey: String

    init(tasks: [TaskItem], project: Project?, stateKey: String) {
        self.tasks = tasks
        self.project = project
        self.stateKey = stateKey
    }

    var body: some View {
        content.background(Token.bg.color)
    }

    @ViewBuilder private var content: some View {
        switch (tasks.isEmpty, isCompact) {
        case (true, _): empty
        case (false, true): TableCardList(tasks: TableSort.sorted(tasks, by: state.sort))
        case (false, false): grid
        }
    }

    private var state: TableViewState {
        TableViewStates.state(for: stateKey, inProject: project != nil, in: stored)
    }

    private var stateBinding: Binding<TableViewState> {
        Binding(get: { state }, set: { stored = TableViewStates.storing($0, for: stateKey, in: stored) })
    }

    private var sortBinding: Binding<[TaskComparator]> {
        Binding(
            get: { state.sort },
            set: { stored = TableViewStates.storingSort($0, for: stateKey, inProject: project != nil, in: stored) })
    }

    private var customization: Binding<TableColumnCustomization<TaskItem>> {
        Binding(
            get: { TableCustomization.make(from: state) },
            set: { value in
                var next = state
                TableCustomization.store(value, into: &next)
                stored = TableViewStates.storing(next, for: stateKey, in: stored)
            })
    }

    private var isCompact: Bool {
        #if os(iOS)
        sizeClass == .compact
        #else
        false
        #endif
    }

    private var grid: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                TableColumnsMenu(state: stateBinding)
            }
            .padding(.horizontal, Spacing.s4)
            .padding(.vertical, Spacing.s2)
            Table(of: TaskItem.self, sortOrder: sortBinding, columnCustomization: customization) {
                columns
            } rows: {
                ForEach(TaskGrouping.byStatus(tasks)) { group in
                    Section {
                        ForEach(TableSort.sorted(group.tasks, by: state.sort)) { TableRow($0) }
                    } header: {
                        TableGroupHeader(status: group.status, count: group.tasks.count)
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
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
