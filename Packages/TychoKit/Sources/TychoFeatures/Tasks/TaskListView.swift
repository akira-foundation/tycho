import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TaskListView: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let groups: [TaskViewGroup]
    let grouping: TaskViewGrouping
    let project: Project?
    let allowsReorder: Bool
    @State private var collapsed: Set<String> = []

    init(
        groups: [TaskViewGroup], grouping: TaskViewGrouping, project: Project?, allowsReorder: Bool,
        initiallyCollapsed: Set<String> = []
    ) {
        self.groups = groups
        self.grouping = grouping
        self.project = project
        self.allowsReorder = allowsReorder
        _collapsed = State(initialValue: initiallyCollapsed)
    }

    init(tasks: [TaskItem], project: Project?) {
        self.init(groups: TaskGrouping.statusGroups(tasks), grouping: .status, project: project, allowsReorder: true)
    }

    private var tasks: [TaskItem] { groups.flatMap(\.tasks) }

    var body: some View {
        List {
            ForEach(groups) { group in
                let status = statusOf(group)
                Section {
                    if !collapsed.contains(group.id) {
                        ForEach(group.tasks) { task in
                            row(task, status: status)
                        }
                        if let project, let status {
                            InlineComposer(placeholder: "Add task") { title in
                                toast.perform {
                                    _ = try TaskActions(context: context).create(
                                        TaskDraft(title: title, status: status), in: project)
                                }
                            }
                        }
                    }
                } header: {
                    header(group, status: status)
                        .dropDestination(for: TaskTransfer.self) { items, _ in
                            guard let status else { return false }
                            return drop(items, into: status, before: nil)
                        }
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .tychoAnimation(value: tasks.movementSignature)
    }

    @ViewBuilder private func row(_ task: TaskItem, status: TaskStatus?) -> some View {
        let base = TaskRow(task: task, showsProject: project == nil).contextMenu { TaskMenu(task: task) }
        switch (status, allowsReorder) {
        case (nil, _):
            base
        case (_, false):
            base.draggable(TaskTransfer(id: task.id))
        case (let status?, true):
            base.draggable(TaskTransfer(id: task.id))
                .dropDestination(for: TaskTransfer.self) { items, _ in
                    return drop(items, into: status, before: task)
                }
        }
    }

    private func statusOf(_ group: TaskViewGroup) -> TaskStatus? {
        guard ListDropPolicy.allowsStatusChange(grouping: grouping) else { return nil }
        return TaskStatus(rawValue: group.id)
    }

    private func header(_ group: TaskViewGroup, status: TaskStatus?) -> some View {
        Button {
            toggle(group.id)
        } label: {
            HStack(spacing: Spacing.s2) {
                Image(systemName: collapsed.contains(group.id) ? "chevron.right" : "chevron.down").font(.caption2)
                if let status {
                    StatusIcon(glyph: status.glyph, color: status.tint)
                }
                Text(group.title).tychoFont(.sm, weight: .semibold)
                Text("\(group.tasks.count)").tychoFont(.xs).foregroundStyle(Token.text4.color)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("group.\(group.id)")
    }

    private func toggle(_ id: String) {
        if collapsed.contains(id) {
            collapsed.remove(id)
        } else {
            collapsed.insert(id)
        }
    }

    private func drop(_ items: [TaskTransfer], into status: TaskStatus, before target: TaskItem?) -> Bool {
        var handled = false
        toast.perform {
            handled = try TaskMoveHandler(context: context).drop(
                items.map(\.id), into: status, before: target, in: tasks)
        }
        return handled
    }
}
