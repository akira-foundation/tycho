import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct NotesEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    let task: TaskItem
    @State private var draft = NotesDraft()
    @State private var flushToken = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            HStack {
                Text("Description").tychoFont(.sm, weight: .semibold)
                Spacer()
                Button(draft.isEditing ? "Done" : "Edit", action: toggleEditing)
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("inspector.notes.edit")
            }
            switch (draft.isEditing, task.notes.isEmpty) {
            case (true, _):
                TextEditor(text: $draft.text)
                    .accessibilityIdentifier("inspector.notes.editor")
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
        .onAppear { router.registerInspectorFlush(flushToken, commitDraft) }
        .onDisappear {
            commitDraft()
            router.unregisterInspectorFlush(flushToken)
        }
    }

    private var rendered: AttributedString {
        let options = AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        return (try? AttributedString(markdown: task.notes, options: options)) ?? AttributedString(task.notes)
    }

    private func commitDraft() {
        guard draft.hasUnsavedText, toast.isStored(task, in: context) else { return }
        draft.commit(storedNotes: { task.notes }) { notes in
            toast.perform { try TaskActions(context: context).edit(task) { $0.notes = notes } }
        }
    }

    private func toggleEditing() {
        guard draft.isEditing else { return draft.begin(with: task.notes) }
        commitDraft()
        draft.finishIfSaved()
    }
}
