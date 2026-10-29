import SwiftUI
import TychoCore
import TychoDesign

extension Calendar {
    static func picker(weekStart: WeekStart) -> Calendar {
        var calendar = DateText.gregorian
        calendar.firstWeekday = weekStart.weekday
        return calendar
    }
}

struct DatePill: View {
    @Environment(\.dateText) private var dateText
    @Environment(\.weekStart) private var weekStart
    let date: Date?
    let emptyText: String
    var color: Color = Token.text.color
    let onChange: (Date?) -> Void
    @State private var picking = false

    static func normalized(_ value: Date) -> Date {
        DayTime.noon(of: value, calendar: DateText.gregorian)
    }

    var body: some View {
        Button {
            picking = true
        } label: {
            Text(date.map(dateText.short) ?? emptyText)
                .monospacedDigit()
                .foregroundStyle(date == nil ? Token.text4.color : color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .popover(isPresented: $picking) { picker }
    }

    private var picker: some View {
        VStack(alignment: .leading, spacing: Spacing.s2) {
            DatePicker(
                "Date",
                selection: Binding(get: { date ?? .now }, set: { commit($0) }),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .environment(\.calendar, Calendar.picker(weekStart: weekStart))
            HStack {
                Button("Today") { commit(.now) }
                Spacer()
                if date != nil {
                    Button("Clear date", role: .destructive) {
                        onChange(nil)
                        picking = false
                    }
                }
            }
        }
        .padding(Spacing.s3)
    }

    private func commit(_ value: Date) {
        onChange(Self.normalized(value))
    }
}
