import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct BoardColumn: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    let group: TaskGroup
    let project: Project?
    let allTasks: [TaskItem]
    @State private var targeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            header
            ScrollView {
                LazyVStack(spacing: Spacing.s2) {
                    ForEach(group.tasks) { task in
                        TaskCard(task: task)
                            .draggable(TaskTransfer(id: task.id)) {
                                TaskCard(task: task).frame(width: 260)
                            }
                            .dropDestination(for: TaskTransfer.self) { items, _ in
                                return drop(items, before: task)
                            }
                            .contextMenu { TaskMenu(task: task) }
                    }
                }
                .padding(.bottom, Spacing.s4)
            }
        }
        .padding(Spacing.s2)
        .frame(width: 280)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            targeted ? AnyShapeStyle(.fill.secondary) : AnyShapeStyle(.fill.quaternary),
            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
        )
        .dropDestination(for: TaskTransfer.self) { items, _ in
            drop(items, before: nil)
        } isTargeted: {
            targeted = $0
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("column.\(group.status.rawValue)")
    }

    private var header: some View {
        HStack(spacing: Spacing.s2) {
            StatusIcon(glyph: group.status.glyph, color: group.status.tint)
            Text(group.status.title).font(.subheadline.weight(.semibold))
            Text("\(group.tasks.count)").font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            if project != nil {
                Button("Add Task to \(group.status.title)", systemImage: "plus") {
                    router.newTask(status: group.status)
                }
                .labelStyle(.iconOnly)
                .buttonStyle(.borderless)
                .help("Add Task")
                .accessibilityIdentifier("column.\(group.status.rawValue).add")
            }
        }
        .padding(.horizontal, Spacing.s1)
        .frame(height: 30)
    }

    private func drop(_ items: [TaskTransfer], before target: TaskItem?) -> Bool {
        var handled = false
        toast.perform {
            handled = try TaskMoveHandler(context: context).drop(
                items.map(\.id), into: group.status, before: target, in: allTasks)
        }
        if handled, let id = items.first?.id, let task = allTasks.first(where: { $0.id == id }) {
            toast.show("Moved \(task.key) to \(group.status.title)")
        }
        return handled
    }
}
