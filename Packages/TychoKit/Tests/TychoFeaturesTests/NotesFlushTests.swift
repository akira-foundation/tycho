#if os(macOS)
import AppKit
import SwiftData
import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct NotesFlushTests {
    @MainActor private struct Host {
        let container: ModelContainer
        let router = Router()
        let window: NSWindow
        let first: TaskItem
        let second: TaskItem

        init() throws {
            container = try TychoSchema.makeContainer(inMemory: true)
            let context = container.mainContext
            first = TaskItem(number: 1, title: "First")
            second = TaskItem(number: 2, title: "Second")
            context.insert(first)
            context.insert(second)
            try context.save()
            let host = NSHostingController(
                rootView: NotesEditor(task: first)
                    .environment(router)
                    .environment(ToastCenter())
                    .modelContainer(container)
                    .frame(width: 400, height: 200))
            window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
                styleMask: .borderless, backing: .buffered, defer: false)
            window.contentViewController = host
            window.contentView?.layoutSubtreeIfNeeded()
            settle(0.5)
        }

        func settle(_ seconds: TimeInterval) {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }

        func notesField() throws -> NSTextField {
            var found: [NSTextField] = []
            collect(window.contentView, into: &found)
            return try #require(found.first)
        }

        func type(_ text: String) throws {
            let field = try notesField()
            window.makeFirstResponder(field)
            let editor = try #require(field.currentEditor() as? NSTextView)
            editor.selectAll(nil)
            editor.insertText(text, replacementRange: NSRange(location: NSNotFound, length: 0))
            settle(0.3)
        }

        private func collect(_ view: NSView?, into fields: inout [NSTextField]) {
            guard let view else { return }
            if let field = view as? NSTextField, field.isEditable { fields.append(field) }
            for subview in view.subviews { collect(subview, into: &fields) }
        }
    }

    @Test func flushingSavesUnsavedNotesToTheEditedTaskOnly() throws {
        let host = try Host()
        #expect(host.router.liveInspectorFlushCount == 1)
        try host.type("Unsaved notes")

        host.router.flushInspectorEdits()

        #expect(host.first.notes == "Unsaved notes")
        #expect(host.second.notes.isEmpty)
    }

    @Test func tearingDownTheEditorSavesUnsavedNotes() throws {
        let host = try Host()
        try host.type("Unsaved notes")

        host.window.contentViewController = nil
        host.settle(0.5)

        #expect(host.first.notes == "Unsaved notes")
        #expect(host.second.notes.isEmpty)
        #expect(host.router.liveInspectorFlushCount == 0)
    }
}
#endif
