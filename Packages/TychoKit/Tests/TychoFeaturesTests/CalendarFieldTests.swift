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
        let controller = NSHostingController(rootView: Form { view }.formStyle(.grouped).frame(width: 420, height: 240))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 240),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false)
        window.isReleasedWhenClosed = false
        window.contentViewController = controller
        window.contentView?.layoutSubtreeIfNeeded()
        RunLoop.main.run(until: Date().addingTimeInterval(0.3))
        window.contentView?.layoutSubtreeIfNeeded()
        return window
    }

    private func release(_ windows: NSWindow...) {
        for window in windows {
            window.contentViewController = nil
            window.close()
        }
        RunLoop.main.run(until: Date().addingTimeInterval(0.5))
    }

    private func views<T: NSView>(of type: T.Type, in view: NSView?) -> [T] {
        guard let view else { return [] }
        let nested = view.subviews.flatMap { views(of: type, in: $0) }
        guard let match = view as? T else { return nested }
        return [match] + nested
    }

    @Test func inspectorDateRowShowsASwitchAndADatePicker() {
        let window = host(OptionalDateRow(title: "Start", date: date) { _ in })
        let other = host(OptionalDateRow(title: "Start", date: nil) { _ in })
        defer { release(window, other) }
        let withDate = window.contentView
        let withoutDate = other.contentView

        #expect(views(of: NSSwitch.self, in: withDate).count == 1)
        #expect(views(of: NSDatePicker.self, in: withDate).count == 1)
        #expect(views(of: NSSwitch.self, in: withoutDate).count == 1)
        #expect(views(of: NSDatePicker.self, in: withoutDate).isEmpty)
    }

    @Test func turningTheDateBackOnPicksTodayAtNoon() {
        var received: Date?? = .none
        let row = OptionalDateRow(title: "Due", date: nil) { received = .some($0) }

        row.isOn.wrappedValue = true

        let calendar = DateText.gregorian
        let expected = calendar.dateComponents([.year, .month, .day], from: .now)
        let picked = received.flatMap { $0 }
        #expect(picked != nil)
        #expect(
            picked.map { calendar.dateComponents([.year, .month, .day, .hour], from: $0) }
                == DateComponents(year: expected.year, month: expected.month, day: expected.day, hour: 12))
    }

    @Test func turningTheDateOffSendsNil() {
        var received: Date?? = .none
        let row = OptionalDateRow(title: "Due", date: date) { received = .some($0) }

        row.isOn.wrappedValue = false

        #expect(received == .some(nil))
    }

    @Test func pickedDatesLandOnNoon() {
        var stored = date
        let field = CalendarField(title: "Due", selection: Binding(get: { stored }, set: { stored = $0 }))
        let calendar = DateText.gregorian
        let morning = calendar.date(from: DateComponents(year: 2026, month: 12, day: 3, hour: 4))!

        field.normalizedSelection.wrappedValue = morning

        #expect(
            calendar.dateComponents([.year, .month, .day, .hour], from: stored)
                == DateComponents(year: 2026, month: 12, day: 3, hour: 12))
    }
}
#endif
