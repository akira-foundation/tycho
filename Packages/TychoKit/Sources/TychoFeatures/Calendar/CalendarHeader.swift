import SwiftUI
import TychoCore

struct CalendarHeader: View {
    @Environment(Router.self) private var router
    @Environment(\.weekStart) private var weekStart
    @Environment(\.dateText) private var dateText

    var body: some View {
        HStack {
            Text(title)
                .font(.title2.bold())
                .accessibilityIdentifier("calendar.title")
            Spacer()
            ControlGroup {
                Button("Previous", systemImage: "chevron.left") { step(-1) }
                    .accessibilityIdentifier("calendar.previous")
                Button("Today") { router.calendarDate = .now }
                    .accessibilityIdentifier("calendar.today")
                Button("Next", systemImage: "chevron.right") { step(1) }
                    .accessibilityIdentifier("calendar.next")
            }
            .fixedSize()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var title: String {
        CalendarGrid.title(
            router.calendarMode, anchor: router.calendarDate, weekStart: weekStart, format: dateText.format,
            calendar: DateText.gregorian)
    }

    private func step(_ offset: Int) {
        router.calendarDate = CalendarGrid.step(
            router.calendarDate, mode: router.calendarMode, by: offset, calendar: DateText.gregorian)
    }
}

struct CalendarModePicker: View {
    @Environment(Router.self) private var router

    var body: some View {
        @Bindable var router = router
        Picker("Calendar Mode", selection: $router.calendarMode) {
            ForEach(CalendarMode.allCases) { Text($0.title).tag($0) }
        }
        .accessibilityIdentifier("calendar.mode")
    }
}
