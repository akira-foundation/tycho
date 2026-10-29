import SwiftUI
import TychoCore
import TychoDesign

struct CalendarToolbar: View {
    @Environment(Router.self) private var router
    @Environment(\.weekStart) private var weekStart
    @Environment(\.dateText) private var dateText
    let tasks: [TaskItem]
    let showsLegend: Bool

    var body: some View {
        @Bindable var router = router
        return HStack(spacing: Spacing.s2) {
            Button("Today") { router.calendarDate = .now }
                .accessibilityIdentifier("calendar.today")
            HStack(spacing: 0) {
                Button("Previous", systemImage: "chevron.left") { step(-1) }
                    .accessibilityIdentifier("calendar.previous")
                Button("Next", systemImage: "chevron.right") { step(1) }
                    .accessibilityIdentifier("calendar.next")
            }
            .labelStyle(.iconOnly)
            Text(title)
                .tychoFont(.md, weight: .semibold)
                .accessibilityIdentifier("calendar.title")
            Spacer()
            if showsLegend {
                CalendarLegend(tasks: tasks)
            }
            Picker("Mode", selection: $router.calendarMode) {
                ForEach(CalendarMode.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
            .accessibilityIdentifier("calendar.mode")
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, Spacing.s4)
        .padding(.vertical, Spacing.s2)
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
