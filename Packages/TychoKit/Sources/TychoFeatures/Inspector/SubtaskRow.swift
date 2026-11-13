import SwiftData
import SwiftUI
import TychoCore

struct SubtaskRow: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let subtask: Subtask
    @State private var title = ""

    var body: some View {
        HStack(spacing: 8) {
            Button {
                toast.perform { try SubtaskActions(context: context).toggle(subtask) }
            } label: {
                Image(systemName: subtask.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(subtask.isDone ? AnyShapeStyle(Color.accentColor) : AnyShapeStyle(.secondary))
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            TextField("Subtask", text: $title, prompt: Text("Subtask"))
                .labelsHidden()
                .multilineTextAlignment(.leading)
                .marksTextEditing()
                .textFieldStyle(.plain)
                .strikethrough(subtask.isDone)
                .foregroundStyle(subtask.isDone ? .secondary : .primary)
                .onSubmit(commit)
            Button("Delete", systemImage: "trash") {
                toast.perform { try SubtaskActions(context: context).delete(subtask) }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
        }
        .onAppear { title = subtask.title }
    }

    private func commit() {
        toast.perform { try SubtaskActions(context: context).rename(subtask, to: title) }
        title = subtask.title
    }
}
