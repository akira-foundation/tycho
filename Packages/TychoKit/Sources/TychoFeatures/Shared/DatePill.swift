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
    let date: Date?
    let emptyText: String
    var color: Color = .primary
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
                .foregroundStyle(date == nil ? AnyShapeStyle(.tertiary) : AnyShapeStyle(color))
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .themedPopover(isPresented: $picking) { picker }
    }

    private var picker: some View {
        VStack(alignment: .leading, spacing: 8) {
            CalendarPicker(
                title: "Date",
                selection: Binding(
                    get: { date ?? .now },
                    set: {
                        commit($0)
                        picking = false
                    }))
            HStack {
                Button("Today") { commit(.now) }
                Spacer()
                if date != nil {
                    Button("Clear Date", role: .destructive) {
                        onChange(nil)
                        picking = false
                    }
                }
            }
        }
        .padding()
    }

    private func commit(_ value: Date) {
        onChange(Self.normalized(value))
    }
}
