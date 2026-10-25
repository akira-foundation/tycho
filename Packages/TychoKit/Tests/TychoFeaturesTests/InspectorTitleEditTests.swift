#if os(macOS)
import AppKit
import SwiftData
import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct InspectorTitleEditTests {
    @MainActor private struct Fixture {
        let task: TaskItem
        let router = Router()
        let window: NSWindow

        init(width: CGFloat) throws {
            let container = try TychoSchema.makeContainer(inMemory: true)
            _ = try DemoSeed.load(into: container.mainContext, now: .now, calendar: .current)
            let tasks = try container.mainContext.fetch(FetchDescriptor<TaskItem>())
            task = try #require(tasks.first { $0.key == "WEB-118" })
            let host = NSHostingController(
                rootView: RootView().environment(router).environment(ToastCenter()).modelContainer(container))
            window = NSWindow(contentViewController: host)
            window.styleMask.insert(.resizable)
            window.setContentSize(NSSize(width: width, height: 800))
            window.makeKeyAndOrderFront(nil)
            settle(0.4)
            router.inspect(task.id)
            settle(0.8)
        }

        func settle(_ seconds: TimeInterval) {
            RunLoop.main.run(until: Date().addingTimeInterval(seconds))
        }

        func rename(in root: NSWindow, to title: String) throws {
            var fields: [NSTextField] = []
            collectEditableFields(root.contentView, into: &fields)
            let field = try #require(
                fields.first { $0.stringValue == task.title && !$0.isHiddenOrHasHiddenAncestor })
            root.makeFirstResponder(field)
            let editor = try #require(field.currentEditor() as? NSTextView)
            editor.selectAll(nil)
            editor.insertText(title, replacementRange: NSRange(location: NSNotFound, length: 0))
            editor.doCommand(by: #selector(NSResponder.insertNewline(_:)))
            settle(0.5)
        }

        private func collectEditableFields(_ view: NSView?, into fields: inout [NSTextField]) {
            guard let view else { return }
            if let field = view as? NSTextField, field.isEditable { fields.append(field) }
            for subview in view.subviews { collectEditableFields(subview, into: &fields) }
        }
    }

    @Test func titleRenamedInTheSheetSurvivesClosingIt() throws {
        let fixture = try Fixture(width: 1000)
        fixture.router.windowWidth = 1000
        fixture.settle(0.5)
        let sheet = try #require(fixture.window.sheets.first)

        try fixture.rename(in: sheet, to: "Renamed in sheet")
        fixture.router.closeInspector()
        fixture.settle(1.5)

        #expect(fixture.task.title == "Renamed in sheet")
        fixture.window.orderOut(nil)
    }

    @Test func titleRenamedInTheSheetSurvivesWideningAndClosingTheColumn() throws {
        let fixture = try Fixture(width: 1000)
        fixture.router.windowWidth = 1000
        fixture.settle(0.5)
        let sheet = try #require(fixture.window.sheets.first)

        try fixture.rename(in: sheet, to: "Renamed in sheet")
        fixture.window.setContentSize(NSSize(width: 1500, height: 800))
        fixture.router.windowWidth = 1500
        fixture.settle(1.0)
        fixture.router.closeInspector()
        fixture.settle(1.5)

        #expect(fixture.task.title == "Renamed in sheet")
        fixture.window.orderOut(nil)
    }
}
#endif
