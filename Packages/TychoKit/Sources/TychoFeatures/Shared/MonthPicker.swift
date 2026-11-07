import SwiftUI
import TychoCore
import TychoDesign

struct MonthPicker: View {
    @Environment(\.dateText) private var dateText
    @Environment(\.weekStart) private var weekStart
    @Binding var selection: Date
    @State private var anchor: Date
    private let calendar = DateText.gregorian
    private static let cellSize: CGFloat = 34

    init(selection: Binding<Date>) {
        _selection = selection
        _anchor = State(initialValue: selection.wrappedValue)
    }

    var body: some View {
        VStack(spacing: Spacing.s2) {
            header
            Grid(horizontalSpacing: 2, verticalSpacing: 2) {
                GridRow {
                    ForEach(CalendarGrid.weekdayLabels(weekStart: weekStart), id: \.self) { label in
                        Text(label.prefix(2))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(width: Self.cellSize)
                    }
                }
                ForEach(Self.weeks(of: cells(around: anchor)), id: \.first?.id) { week in
                    GridRow {
                        ForEach(week) { dayButton($0) }
                    }
                }
            }
        }
        .accessibilityIdentifier("calendar.picker")
    }

    private var header: some View {
        HStack(spacing: Spacing.s1) {
            Text(CalendarGrid.title(.month, anchor: anchor, weekStart: weekStart, calendar: calendar))
                .font(.headline)
                .accessibilityIdentifier("calendar.picker.title")
            Spacer()
            Button("Previous Month", systemImage: "chevron.left") { step(by: -1) }
            Button("Today", systemImage: "circle.fill") { anchor = .now }
                .imageScale(.small)
            Button("Next Month", systemImage: "chevron.right") { step(by: 1) }
        }
        .labelStyle(.iconOnly)
        .buttonStyle(.borderless)
    }

    private func dayButton(_ cell: CalendarCell) -> some View {
        let selected = isSelected(cell)
        return Button {
            pick(cell.date)
        } label: {
            Text("\(cell.day)")
                .font(.callout.weight(selected || cell.isToday ? .semibold : .regular))
                .monospacedDigit()
                .foregroundStyle(foreground(cell, selected: selected))
                .frame(width: Self.cellSize, height: Self.cellSize)
                .background {
                    if selected {
                        Circle().fill(Color.accentColor)
                    }
                }
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(dateText.long(cell.date))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func foreground(_ cell: CalendarCell, selected: Bool) -> AnyShapeStyle {
        if selected { return AnyShapeStyle(Token.onAccent.color) }
        if cell.isToday { return AnyShapeStyle(Color.accentColor) }
        return cell.isInMonth ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary)
    }

    private func step(by offset: Int) {
        anchor = CalendarGrid.step(anchor, mode: .month, by: offset, calendar: calendar)
    }

    func cells(around date: Date) -> [CalendarCell] {
        CalendarGrid.month(containing: date, weekStart: weekStart, today: .now, calendar: calendar)
    }

    func isSelected(_ cell: CalendarCell) -> Bool {
        calendar.isDate(cell.date, inSameDayAs: selection)
    }

    func pick(_ date: Date) {
        selection = DatePill.normalized(date)
    }

    static func weeks(of cells: [CalendarCell]) -> [[CalendarCell]] {
        stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<min($0 + 7, cells.count)]) }
    }
}
