struct NotesDraft {
    var text = ""
    private var syncedNotes = ""

    var hasUnsavedText: Bool { text != syncedNotes }

    mutating func begin(with storedNotes: String) {
        text = storedNotes
        syncedNotes = storedNotes
    }

    mutating func discardEdits() {
        text = syncedNotes
    }

    mutating func commit(storedNotes: () -> String, save: (String) -> Void) {
        guard hasUnsavedText else { return }
        if text != storedNotes() { save(text) }
        syncedNotes = storedNotes()
    }
}
