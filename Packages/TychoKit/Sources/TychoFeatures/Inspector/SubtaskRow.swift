import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct SubtaskRow: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let subtask: Subtask
    @State private var title = ""

    var body: some View {
        HStack(spacing: Spacing.s2) {
            Button {
                toast.perform { try SubtaskActions(context: context).toggle(subtask) }
            } label: {
                Image(systemName: subtask.isDone ? "checkmark.square.fill" : "square")
                    .foregroundStyle(subtask.isDone ? Token.stDone.color : Token.text4.color)
            }
            .buttonStyle(.plain)
            TextField("Subtask", text: $title)
                .textFieldStyle(.plain)
                .strikethrough(subtask.isDone)
                .onSubmit(commit)
            Button("Delete", systemImage: "trash") {
                toast.perform { try SubtaskActions(context: context).delete(subtask) }
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.plain)
            .foregroundStyle(Token.text4.color)
        }
        .tychoFont(.base)
        .frame(minHeight: 28)
        .onAppear { title = subtask.title }
    }

    private func commit() {
        toast.perform { try SubtaskActions(context: context).rename(subtask, to: title) }
        title = subtask.title
    }
}
