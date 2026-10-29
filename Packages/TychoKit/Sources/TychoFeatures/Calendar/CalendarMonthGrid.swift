import SwiftUI
import TychoCore
import TychoDesign

struct CalendarMonthGrid: View {
    @Environment(Router.self) private var router
    @Environment(\.weekStart) private var weekStart
    let tasks: [TaskItem]
    let events: [CalendarEvent]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        let calendar = DateText.gregorian
        let cells = CalendarGrid.month(
            containing: router.calendarDate, weekStart: weekStart, today: .now, calendar: calendar)
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(CalendarGrid.weekdayLabels(weekStart: weekStart), id: \.self) { label in
                    Text(label)
                        .tychoFont(.xs, weight: .medium)
                        .foregroundStyle(Token.text3.color)
                        .frame(maxWidth: .infinity, minHeight: 28)
                }
            }
            Divider()
            ScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(cells) { cell in
                        CalendarDayCell(
                            cell: cell,
                            items: CalendarDay.items(on: cell.date, events: events, tasks: tasks, calendar: calendar),
                            tasks: tasks)
                    }
                }
            }
        }
    }
}
