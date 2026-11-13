import Testing

@testable import TychoFeatures

struct NotesDraftTests {
    @Test func aCommittedDraftIsSaved() {
        var stored = "Old"
        var draft = NotesDraft()
        draft.begin(with: stored)
        draft.text = "New"

        draft.commit(storedNotes: { stored }) { stored = $0 }

        #expect(stored == "New")
        #expect(!draft.hasUnsavedText)
    }

    @Test func aDraftWhoseSaveFailedStaysUnsaved() {
        let stored = "Old"
        var draft = NotesDraft()
        draft.begin(with: stored)
        draft.text = "New"

        draft.commit(storedNotes: { stored }) { _ in }

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

        #expect(saved.isEmpty)
        #expect(!draft.hasUnsavedText)
    }

    @Test func aDraftAlreadyStoredElsewhereIsNotWrittenAgain() {
        var stored = "Old"
        var draft = NotesDraft()
        draft.begin(with: stored)
        draft.text = "Same"
        stored = "Same"
        var saved: [String] = []

        draft.commit(storedNotes: { stored }) { saved.append($0) }

        #expect(saved.isEmpty)
        #expect(!draft.hasUnsavedText)
    }
}
