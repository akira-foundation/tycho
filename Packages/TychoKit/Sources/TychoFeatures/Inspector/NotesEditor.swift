import SwiftData
import SwiftUI
import TychoCore

struct NotesEditor: View {
    @Environment(\.modelContext) private var context
    @Environment(\.fontResolutionContext) private var fontContext
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    let task: TaskItem
    @State private var draft = NotesDraft()
    @State private var text = AttributedString()
    @State private var loadedText = AttributedString()
    @State private var flushToken = UUID()
    @FocusState private var isFocused: Bool

    var body: some View {
        TextEditor(text: $text)
            .attributedTextFormattingDefinition(NotesAttributes.self)
            .frame(minHeight: 120)
            .overlay(alignment: .topLeading) { placeholder }
            .marksTextEditing(isFocused: isFocused)
            .focused($isFocused)
            .onChange(of: text) { recordEdit() }
            .onChange(of: isFocused) { _, focused in
                if !focused { commitDraft() }
            }
            .accessibilityIdentifier("inspector.notes")
            .onAppear {
                load(task.notes)
                router.registerInspectorFlush(flushToken, commitDraft)
            }
            .onChange(of: task.notes) { syncFromStore() }
            .onDisappear {
                commitDraft()
                router.unregisterInspectorFlush(flushToken)
            }
    }

    @ViewBuilder private var placeholder: some View {
        if text.characters.isEmpty {
            Text("Notes")
                .foregroundStyle(.tertiary)
                .padding(.leading, 5)
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    private func load(_ notes: String) {
        draft.begin(with: notes)
        text = NotesMarkdown.attributed(notes)
        loadedText = text
    }

    private func recordEdit() {
        guard text != loadedText else { return }
        draft.text = NotesMarkdown.markdown(text, context: fontContext)
    }

    private func syncFromStore() {
        guard !draft.hasUnsavedText else { return }
        load(task.notes)
    }

    private func commitDraft() {
        guard draft.hasUnsavedText, toast.isStored(task, in: context) else { return }
        draft.commit(storedNotes: { task.notes }) { notes in
            toast.perform { try TaskActions(context: context).edit(task) { $0.notes = notes } }
        }
    }
}

struct NotesAttributes: AttributeScope {
    let font: AttributeScopes.SwiftUIAttributes.FontAttribute
    let strikethroughStyle: AttributeScopes.SwiftUIAttributes.StrikethroughStyleAttribute
    let link: AttributeScopes.FoundationAttributes.LinkAttribute
}
