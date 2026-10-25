#if os(macOS)
import AppKit
import SwiftData
import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct InspectorHostFixture {
    let container: ModelContainer
    let task: TaskItem
    let router = Router()
    let window: NSWindow

    init(width: CGFloat) throws {
        container = try TychoSchema.makeContainer(inMemory: true)
        _ = try DemoSeed.load(into: container.mainContext, now: .now, calendar: .current)
        let tasks = try container.mainContext.fetch(FetchDescriptor<TaskItem>())
        task = try #require(tasks.first { $0.key == "WEB-118" })
        let host = NSHostingController(
            rootView: RootView().environment(router).environment(ToastCenter()).modelContainer(container))
        window = NSWindow(contentViewController: host)
        window.styleMask.insert(.resizable)
        window.setContentSize(NSSize(width: width, height: 800))
        window.makeKeyAndOrderFront(nil)
        router.updateWindowWidth(width)
        settle(0.4)
        router.inspect(task.id)
        settle(0.8)
    }

    func settle(_ seconds: TimeInterval) {
        RunLoop.main.run(until: Date().addingTimeInterval(seconds))
    }

    func resize(to width: CGFloat) {
        window.setContentSize(NSSize(width: width, height: 800))
        router.updateWindowWidth(width)
        settle(1.0)
    }

    func editableFields(in root: NSWindow) -> [NSTextField] {
        var fields: [NSTextField] = []
        collect(root.contentView, into: &fields)
        return fields
    }

    func titleField(in root: NSWindow, current: String) throws -> NSTextField {
        try #require(
            editableFields(in: root).first { $0.stringValue == current && !$0.isHiddenOrHasHiddenAncestor })
    }

    func estimateField(in root: NSWindow) throws -> NSTextField {
        try #require(editableFields(in: root).first { $0.placeholderString == "e.g. 2d" })
    }

    func type(_ text: String, into field: NSTextField, submit: Bool) throws {
        let root = try #require(field.window)
        root.makeFirstResponder(field)
        let editor = try #require(field.currentEditor() as? NSTextView)
        editor.selectAll(nil)
        editor.insertText(text, replacementRange: NSRange(location: NSNotFound, length: 0))
        if submit { editor.doCommand(by: #selector(NSResponder.insertNewline(_:))) }
        settle(0.4)
    }

    func renameInSheet(to title: String, submit: Bool) throws {
        let sheet = try #require(window.sheets.first)
        try type(title, into: titleField(in: sheet, current: task.title), submit: submit)
    }

    private func collect(_ view: NSView?, into fields: inout [NSTextField]) {
        guard let view else { return }
        if let field = view as? NSTextField, field.isEditable { fields.append(field) }
        for subview in view.subviews { collect(subview, into: &fields) }
    }
}
#endif
