import SwiftData
import SwiftUI
import TychoCore

struct CalendarWeekView: View {
    @Environment(Router.self) private var router
    @Environment(\.weekStart) private var weekStart
    let tasks: [TaskItem]
    let events: [CalendarEvent]

    static func weekdayName(for cell: CalendarCell) -> String { DateText.weekdayNames[cell.weekday - 1] }

    var body: some View {
        let calendar = DateText.gregorian
        let cells = CalendarGrid.week(
            containing: router.calendarDate, weekStart: weekStart, today: .now, calendar: calendar)
        HStack(alignment: .top, spacing: 0) {
            ForEach(cells) { cell in
                CalendarWeekColumn(
                    cell: cell,
                    items: CalendarDay.items(on: cell.date, events: events, tasks: tasks, calendar: calendar),
                    tasks: tasks)
                Divider()
            }
        }
    }
}

struct CalendarWeekColumn: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    let cell: CalendarCell
    let items: [CalendarItem]
    let tasks: [TaskItem]
    @State private var targeted = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if items.isEmpty {
                        Text("No tasks").font(.caption).foregroundStyle(.tertiary).padding(4)
                    }
                    ForEach(items) { item in
                        switch item {
                        case .event(let event): WeekEventCard(event: event)
                        case .task(let task): WeekTaskCard(task: task)
                        }
                    }
                }
                .padding(4)
            }
            .frame(maxHeight: .infinity)
            .background(targeted ? Color.accentColor.opacity(0.12) : Color.clear)
            .dropDestination(for: TaskTransfer.self) { transfers, _ in
                return CalendarDropHandler(context: context).announceDrop(
                    transfers.map(\.id), on: cell.date, in: tasks, toast: toast, dateText: dateText)
            } isTargeted: {
                targeted = $0
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("calendar.week.\(cell.key)")
    }

    private var header: some View {
        HStack(spacing: 4) {
            Text(CalendarWeekView.weekdayName(for: cell)).font(.callout).foregroundStyle(.secondary)
            dayNumber
            Spacer()
            Button("Add task on \(dateText.short(cell.date))", systemImage: "plus") {
                router.newTask(due: DayTime.noon(of: cell.date, calendar: DateText.gregorian))
            }
            .labelStyle(.iconOnly)
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, 8)
        .frame(height: 40)
    }

    private var dayNumber: some View {
        Text("\(cell.day)")
            .font(.title3.weight(.semibold))
            .monospacedDigit()
            .foregroundStyle(cell.isToday ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
            .frame(minWidth: 30, minHeight: 30)
            .background(cell.isToday ? Color.accentColor : Color.clear, in: Circle())
            .accessibilityLabel(cell.isToday ? "Today, \(cell.day)" : "\(cell.day)")
            .accessibilityAddTraits(cell.isToday ? .isSelected : [])
    }
}
