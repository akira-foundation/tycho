import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct NotesEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    let task: TaskItem
    @State private var editing = false
    @State private var text = ""
    @State private var syncedNotes = ""
    @State private var flushToken = UUID()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            HStack {
                Text("Description").tychoFont(.sm, weight: .semibold)
                Spacer()
                Button(editing ? "Done" : "Edit", action: toggleEditing)
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("inspector.notes.edit")
            }
            switch (editing, task.notes.isEmpty) {
            case (true, _):
                TextEditor(text: $text)
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
        guard editing, text != syncedNotes, toast.isStored(task, in: context) else { return }
        if text != task.notes {
            toast.perform { try TaskActions(context: context).edit(task) { $0.notes = text } }
        }
        syncedNotes = task.notes
    }

    private func toggleEditing() {
        guard editing else {
            text = task.notes
            syncedNotes = task.notes
            editing = true
            return
        }
        commitDraft()
        editing = text != syncedNotes
    }
}
