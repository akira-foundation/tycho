import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct TaskListView: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let tasks: [TaskItem]
    let project: Project?
    @State private var collapsed: Set<TaskStatus> = []

    var body: some View {
        List {
            ForEach(TaskGrouping.byStatus(tasks)) { group in
                Section {
                    if !collapsed.contains(group.status) {
                        ForEach(group.tasks) { task in
                            TaskRow(task: task, showsProject: project == nil)
                                .draggable(TaskTransfer(id: task.id))
                                .dropDestination(for: TaskTransfer.self) { items, _ in
                                    drop(items, into: group.status, before: task)
                                }
                                .contextMenu { TaskMenu(task: task) }
                        }
                        if let project {
                            InlineComposer(placeholder: "Add task") { title in
                                toast.perform {
                                    _ = try TaskActions(context: context).create(
                                        TaskDraft(title: title, status: group.status), in: project)
                                }
                            }
                        }
                    }
                } header: {
                    header(group)
                        .dropDestination(for: TaskTransfer.self) { items, _ in
                            drop(items, into: group.status, before: nil)
                        }
                }
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
    }

    private func header(_ group: TaskGroup) -> some View {
        Button {
            toggle(group.status)
        } label: {
            HStack(spacing: Spacing.s2) {
                Image(systemName: collapsed.contains(group.status) ? "chevron.right" : "chevron.down").font(.caption2)
                StatusIcon(glyph: group.status.glyph, color: group.status.tint)
                Text(group.status.title).tychoFont(.sm, weight: .semibold)
                Text("\(group.tasks.count)").tychoFont(.xs).foregroundStyle(Token.text4.color)
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("group.\(group.status.rawValue)")
    }

    private func toggle(_ status: TaskStatus) {
        if collapsed.contains(status) {
            collapsed.remove(status)
        } else {
            collapsed.insert(status)
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
