import SwiftData
import SwiftUI
import TychoCore

struct NotesEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    let task: TaskItem
    @State private var draft = NotesDraft()
    @State private var flushToken = UUID()

    var body: some View {
        Section {
            switch (draft.isEditing, task.notes.isEmpty) {
            case (true, _):
                TextEditor(text: $draft.text)
                    .marksTextEditing()
                    .accessibilityIdentifier("inspector.notes.editor")
                    .frame(minHeight: 120)
            case (false, true):
                Text("No Description").foregroundStyle(.secondary)
            case (false, false):
                Text(rendered)
                    .textSelection(.enabled)
            }
        } header: {
            HStack {
                Text("Description")
                Spacer()
                Button(draft.isEditing ? "Done" : "Edit", action: toggleEditing)
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("inspector.notes.edit")
            }
        }
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
