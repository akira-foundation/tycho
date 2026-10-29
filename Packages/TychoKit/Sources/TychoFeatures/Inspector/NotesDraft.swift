struct NotesDraft {
    private(set) var isEditing = false
    var text = ""
    private var syncedNotes = ""

    var hasUnsavedText: Bool { isEditing && text != syncedNotes }

    mutating func begin(with storedNotes: String) {
        text = storedNotes
        syncedNotes = storedNotes
        isEditing = true
    }

    mutating func commit(storedNotes: () -> String, save: (String) -> Void) {
        guard hasUnsavedText else { return }
        if text != storedNotes() { save(text) }
        syncedNotes = storedNotes()
    }

    mutating func finishIfSaved() {
        isEditing = hasUnsavedText
    }
}
