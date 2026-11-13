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
    @FocusState private var isFocused: Bool

    var body: some View {
        TextField("Notes", text: $draft.text, prompt: Text("Notes"), axis: .vertical)
            .labelsHidden()
            .lineLimit(3...)
            .marksTextEditing(isFocused: isFocused)
            .focused($isFocused)
            .onSubmit(commitDraft)
            .onChange(of: isFocused) { _, focused in
                if !focused { commitDraft() }
            }
            .accessibilityIdentifier("inspector.notes")
            .onAppear {
                draft.begin(with: task.notes)
                router.registerInspectorFlush(flushToken, commitDraft)
            }
            .onChange(of: task.notes) { syncFromStore() }
            .onDisappear {
                commitDraft()
                router.unregisterInspectorFlush(flushToken)
            }
    }

    private func syncFromStore() {
        guard !draft.hasUnsavedText else { return }
        draft.begin(with: task.notes)
    }

    private func commitDraft() {
        guard draft.hasUnsavedText, toast.isStored(task, in: context) else { return }
        draft.commit(storedNotes: { task.notes }) { notes in
            toast.perform { try TaskActions(context: context).edit(task) { $0.notes = notes } }
        }
    }
}
