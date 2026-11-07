#if os(macOS)
import AppKit
import SwiftUI
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct CalendarFieldTests {
    private let date = DateText.gregorian.date(from: DateComponents(year: 2026, month: 11, day: 15, hour: 12))!

    private func host(_ view: some View) -> NSWindow {
        let window = NSWindow(contentViewController: NSHostingController(rootView: view.frame(width: 360)))
        window.makeKeyAndOrderFront(nil)
        settle()
        return window
    }

    private func settle() {
        RunLoop.main.run(until: Date().addingTimeInterval(0.6))
    }

    private func views<T: NSView>(of type: T.Type, in view: NSView?) -> [T] {
        guard let view else { return [] }
        let nested = view.subviews.flatMap { views(of: type, in: $0) }
        guard let match = view as? T else { return nested }
        return [match] + nested
    }

    private func datePickers() -> [NSDatePicker] {
        NSApp.windows.flatMap { views(of: NSDatePicker.self, in: $0.contentView?.superview) }
    }

    @Test func inspectorDateRowShowsNoStepperField() {
        let window = host(OptionalDateRow(title: "Start", date: date) { _ in })
        defer { window.close() }

        #expect(views(of: NSDatePicker.self, in: window.contentView).isEmpty)
    }

    @Test func openDateFieldShowsAGraphicalCalendar() {
        let window = host(CalendarField(title: "Due", selection: .constant(date), isPicking: true))
        defer { window.close() }

        #expect(views(of: NSDatePicker.self, in: window.contentView).isEmpty)
        #expect(datePickers().contains { $0.datePickerStyle == .clockAndCalendar })
    }
}
#endif
