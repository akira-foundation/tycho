import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct CalendarDayCell: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    let cell: CalendarCell
    let items: [CalendarItem]
    let tasks: [TaskItem]
    @State private var hovering = false
    @State private var showingDay = false
    @State private var targeted = false

    var body: some View {
        let chips = CalendarDay.chips(for: items)
        VStack(alignment: .leading, spacing: 2) {
            HStack {
                dayNumber
                Spacer()
                addButton
            }
            ForEach(chips.shown) { CalendarChip(item: $0) }
            if chips.overflow > 0 {
                Button("+\(chips.overflow) more") { showingDay = true }
                    .buttonStyle(.plain)
                    .tychoFont(.xxs, weight: .medium)
                    .foregroundStyle(Token.text3.color)
                    .popover(isPresented: $showingDay) { DayListPopover(day: cell.date) }
            }
            Spacer(minLength: 0)
        }
        .padding(Spacing.s1)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
        .background(background)
        .overlay(Rectangle().strokeBorder(Token.divider.color, lineWidth: 0.5))
        .onHover { hovering = $0 }
        .dropDestination(for: TaskTransfer.self) { transfers, _ in
            return CalendarDropHandler(context: context).announceDrop(
                transfers.map(\.id), on: cell.date, in: tasks, toast: toast, dateText: dateText)
        } isTargeted: {
            targeted = $0
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("calendar.day.\(cell.key)")
    }

    private var dayNumber: some View {
        Text("\(cell.day)")
            .tychoFont(.xs, weight: cell.isToday ? .semibold : .regular)
            .monospacedDigit()
            .foregroundStyle(numberColor)
            .frame(minWidth: 22, minHeight: 22)
            .background(cell.isToday ? Color.accentColor : Color.clear, in: Circle())
    }

    private var numberColor: Color {
        switch (cell.isToday, cell.isInMonth) {
        case (true, _): Token.onAccent.color
        case (false, true): Token.text2.color
        case (false, false): Token.text4.color
        }
    }

    private var background: Color {
        switch (targeted, cell.isInMonth) {
        case (true, _): Token.surface3.color
        case (false, true): Token.surface.color
        case (false, false): Token.sunken.color
        }
    }

    private var addButton: some View {
        Button("Add task on \(dateText.short(cell.date))", systemImage: "plus") {
            router.newTask(due: DayTime.noon(of: cell.date, calendar: DateText.gregorian))
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.plain)
        .foregroundStyle(Token.text3.color)
        .opacity(Self.alwaysShowsAdd || hovering ? 1 : 0)
    }

    private static var alwaysShowsAdd: Bool {
        #if os(iOS)
        true
        #else
        false
        #endif
    }
}
