import SwiftData
import SwiftUI
import TychoCore

struct CalendarDayCell: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    @Environment(Router.self) private var router
    @Environment(\.dateText) private var dateText
    @Environment(\.isCompactWidth) private var isCompactWidth
    let cell: CalendarCell
    let items: [CalendarItem]
    let tasks: [TaskItem]
    @State private var hovering = false
    @State private var showingDay = false
    @State private var targeted = false

    var body: some View {
        Group {
            if isCompactWidth { compact } else { regular }
        }
        .background(targeted ? Color.accentColor.opacity(0.12) : Color.clear)
        .overlay(alignment: .top) { Rectangle().fill(.separator).frame(height: 0.5) }
        .overlay(alignment: .trailing) { Rectangle().fill(.separator).frame(width: 0.5) }
        .contentShape(Rectangle())
        .onHover { hovering = $0 }
        .dropDestination(for: TaskTransfer.self) { transfers, _ in
            return CalendarDropHandler(context: context).announceDrop(
                transfers.map(\.id), on: cell.date, in: tasks, toast: toast, dateText: dateText)
        } isTargeted: {
            targeted = $0
        }
        .popover(isPresented: $showingDay) { DayListPopover(day: cell.date) }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("calendar.day.\(cell.key)")
    }

    private var compact: some View {
        Button {
            showingDay = !items.isEmpty
        } label: {
            VStack(spacing: 4) {
                dayNumber
                HStack(spacing: 3) {
                    ForEach(items.prefix(3)) { item in
                        Circle().fill(Self.tint(of: item)).frame(width: 5, height: 5)
                    }
                }
                .frame(height: 5)
                Spacer(minLength: 0)
            }
            .padding(.top, 4)
            .frame(maxWidth: .infinity, minHeight: 56)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    static func tint(of item: CalendarItem) -> Color {
        switch item {
        case .event(let event): event.project?.color.tint ?? .gray
        case .task(let task): task.project?.color.tint ?? .gray
        }
    }

    private var regular: some View {
        let chips = CalendarDay.chips(for: items)
        return VStack(alignment: .leading, spacing: 1) {
            HStack {
                addButton
                Spacer()
                dayNumber
            }
            ForEach(chips.shown) { CalendarChip(item: $0) }
            if chips.overflow > 0 {
                Button("\(chips.overflow) more") { showingDay = true }
                    .buttonStyle(.plain)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(4)
        .frame(maxWidth: .infinity, minHeight: 112, alignment: .topLeading)
    }

    private var dayNumber: some View {
        Text("\(cell.day)")
            .font(.callout.weight(cell.isToday ? .semibold : .regular))
            .monospacedDigit()
            .foregroundStyle(numberStyle)
            .frame(minWidth: 24, minHeight: 24)
            .background(cell.isToday ? Color.accentColor : Color.clear, in: Circle())
            .accessibilityLabel(cell.isToday ? "Today, \(cell.day)" : "\(cell.day)")
            .accessibilityAddTraits(cell.isToday ? .isSelected : [])
    }

    private var numberStyle: AnyShapeStyle {
        if cell.isToday { return AnyShapeStyle(.white) }
        return cell.isInMonth ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary)
    }

    private var addButton: some View {
        Button("Add task on \(dateText.short(cell.date))", systemImage: "plus") {
            router.newTask(due: DayTime.noon(of: cell.date, calendar: DateText.gregorian))
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
        .font(.caption)
        .opacity(hovering ? 1 : 0)
    }
}
