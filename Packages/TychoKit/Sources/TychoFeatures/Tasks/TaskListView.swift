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
    @State private var collapsed: Set<String> = []

    init(groups: [TaskViewGroup], grouping: TaskViewGrouping, project: Project?) {
        self.groups = groups
        self.grouping = grouping
        self.project = project
    }

    init(tasks: [TaskItem], project: Project?) {
        self.init(groups: TaskGrouping.statusGroups(tasks), grouping: .status, project: project)
    }

    private var tasks: [TaskItem] { groups.flatMap(\.tasks) }

    var body: some View {
        List {
            ForEach(groups) { group in
                let status = statusOf(group)
                Section {
                    if !collapsed.contains(group.id) {
                        ForEach(group.tasks) { task in
                            TaskRow(task: task, showsProject: project == nil)
                                .draggable(TaskTransfer(id: task.id))
                                .dropDestination(for: TaskTransfer.self) { items, _ in
                                    guard let status else { return false }
                                    return drop(items, into: status, before: task)
                                }
                                .contextMenu { TaskMenu(task: task) }
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

    private func statusOf(_ group: TaskViewGroup) -> TaskStatus? {
        guard grouping == .status else { return nil }
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
