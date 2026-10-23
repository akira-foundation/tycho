import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct BoardColumn: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let group: TaskGroup
    let project: Project
    let allTasks: [TaskItem]
    @Binding var collapsed: Bool
    @State private var targeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            header
            if !collapsed {
                ScrollView {
                    LazyVStack(spacing: Spacing.s2) {
                        ForEach(group.tasks) { task in
                            TaskCard(task: task)
                                .draggable(TaskTransfer(id: task.id)) {
                                    TaskCard(task: task).frame(width: 260).shadowDrag()
                                }
                                .dropDestination(for: TaskTransfer.self) { items, _ in drop(items, before: task) }
                                .contextMenu { TaskMenu(task: task) }
                        }
                        InlineComposer(placeholder: "Add task") { title in
                            toast.perform {
                                _ = try TaskActions(context: context).create(
                                    TaskDraft(title: title, status: group.status), in: project)
                            }
                        }
                        .padding(.horizontal, Spacing.s2)
                    }
                    .padding(.bottom, Spacing.s4)
                }
            }
        }
        .padding(Spacing.s2)
        .frame(width: collapsed ? 48 : 280)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(
            targeted ? Token.surface3.color : Token.surface2.color,
            in: RoundedRectangle(cornerRadius: Radius.lg, style: .continuous)
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
            if !collapsed {
                Text(group.status.title).tychoFont(.sm, weight: .semibold)
                Text("\(group.tasks.count)").tychoFont(.xs).foregroundStyle(Token.text4.color)
                Spacer()
            }
            Button(
                collapsed ? "Expand" : "Collapse",
                systemImage: collapsed ? "arrow.right.to.line" : "arrow.left.to.line"
            ) {
                collapsed.toggle()
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .foregroundStyle(Token.text4.color)
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
