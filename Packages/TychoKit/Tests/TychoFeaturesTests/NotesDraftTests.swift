import Testing

@testable import TychoFeatures

struct NotesDraftTests {
    @Test func aSavedDraftLeavesEditMode() {
        var stored = "Old"
        var draft = NotesDraft()
        draft.begin(with: stored)
        draft.text = "New"

        draft.commit(storedNotes: { stored }) { stored = $0 }
        draft.finishIfSaved()

        #expect(stored == "New")
        #expect(!draft.isEditing)
    }

    @Test func aDraftWhoseSaveFailedStaysInEditMode() {
        let stored = "Old"
        var draft = NotesDraft()
        draft.begin(with: stored)
        draft.text = "New"

        draft.commit(storedNotes: { stored }) { _ in }
        draft.finishIfSaved()

        #expect(draft.isEditing)
        #expect(draft.text == "New")
        #expect(draft.hasUnsavedText)
    }

    @Test func anUnchangedDraftDoesNotRevertAnEditMadeElsewhere() {
        var stored = "Old"
        var draft = NotesDraft()
        draft.begin(with: stored)
        stored = "Elsewhere"
        var saved: [String] = []

        draft.commit(storedNotes: { stored }) { saved.append($0) }
        draft.finishIfSaved()

        #expect(saved.isEmpty)
        #expect(!draft.isEditing)
    }

    @Test func aDraftAlreadyStoredElsewhereIsNotWrittenAgain() {
        var stored = "Old"
        var draft = NotesDraft()
        draft.begin(with: stored)
        draft.text = "Same"
        stored = "Same"
        var saved: [String] = []

        draft.commit(storedNotes: { stored }) { saved.append($0) }
        draft.finishIfSaved()

        #expect(saved.isEmpty)
        #expect(!draft.isEditing)
    }
}
