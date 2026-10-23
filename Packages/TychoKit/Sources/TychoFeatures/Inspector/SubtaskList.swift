import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct SubtaskList: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s1) {
            HStack {
                Text("Subtasks").tychoFont(.sm, weight: .semibold)
                if let summary = TaskCard.subtaskSummary(task) {
                    Text(summary).tychoFont(.xs).foregroundStyle(Token.text4.color)
                }
            }
            ForEach(task.orderedSubtasks) { subtask in
                SubtaskRow(subtask: subtask)
                    .draggable(subtask.id.uuidString)
                    .dropDestination(for: String.self) { items, _ -> Bool in
                        reorder(items, onto: subtask)
                    }
            }
            InlineComposer(placeholder: "Add subtask") { title in
                toast.perform { try SubtaskActions(context: context).add(title, to: task) }
            }
        }
    }

    private func reorder(_ items: [String], onto target: Subtask) -> Bool {
        guard let id = items.first.flatMap(UUID.init(uuidString:)),
            let moved = task.orderedSubtasks.first(where: { $0.id == id }),
            let index = task.orderedSubtasks.filter({ $0 !== moved }).firstIndex(where: { $0 === target })
        else { return false }
        toast.perform { try SubtaskActions(context: context).move(moved, to: index) }
        return true
    }
}
