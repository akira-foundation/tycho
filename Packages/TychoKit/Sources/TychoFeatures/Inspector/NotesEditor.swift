import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct NotesEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let task: TaskItem
    @State private var editing = false
    @State private var text = ""

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            HStack {
                Text("Description").tychoFont(.sm, weight: .semibold)
                Spacer()
                Button(editing ? "Done" : "Edit", action: toggleEditing)
                    .buttonStyle(.borderless)
            }
            switch (editing, task.notes.isEmpty) {
            case (true, _):
                TextEditor(text: $text)
                    .frame(minHeight: 120)
                    .scrollContentBackground(.hidden)
                    .background(Token.sunken.color, in: RoundedRectangle(cornerRadius: Radius.md))
            case (false, true):
                Text("Add a description…").foregroundStyle(Token.text4.color)
            case (false, false):
                Text(rendered)
                    .textSelection(.enabled)
            }
        }
        .tychoFont(.base)
    }

    private var rendered: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: task.notes, options: options)) ?? AttributedString(task.notes)
    }

    private func toggleEditing() {
        if editing {
            toast.perform { try TaskActions(context: context).edit(task) { $0.notes = text } }
        } else {
            text = task.notes
        }
        editing.toggle()
    }
}
