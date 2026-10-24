import Foundation

public enum TimelineZoom: String, CaseIterable, Sendable, Identifiable {
    case week
    case month

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .week: "Weeks"
        case .month: "Months"
        }
    }

    public var dayWidth: Double {
        switch self {
        case .week: 32
        case .month: 11
        }
    }

    public var dayCount: Int {
        switch self {
        case .week: 91
        case .month: 238
        }
    }

    var leadDays: Int {
        switch self {
        case .week: 21
        case .month: 56
        }
    }
}

public struct BarFrame: Equatable, Sendable {
    public let x: Double
    public let width: Double
}

public struct TimelineBlock: Equatable, Sendable, Identifiable {
    public let x: Double
    public let width: Double
    public let title: String
    public let isToday: Bool

    public var id: Double { x }
}

public struct TimelineLayout: Sendable {
    public static let rowHeight: Double = 36
    public static let todayScrollLead: Double = 160
    public static let insideLabelWidth: Double = 110

    public let zoom: TimelineZoom
    public let rangeStart: Date
    public let calendar: Calendar
    private let today: Date

    public init(zoom: TimelineZoom, today: Date, weekStart: WeekStart, calendar: Calendar) {
        self.zoom = zoom
        self.calendar = calendar
        let start = calendar.startOfDay(for: today)
        self.today = start
        let lead = calendar.date(byAdding: .day, value: -zoom.leadDays, to: start) ?? start
        rangeStart = CalendarGrid.startOfWeek(lead, weekStart: weekStart, calendar: calendar)
    }

    public var dayWidth: Double { zoom.dayWidth }
    public var width: Double { Double(zoom.dayCount) * dayWidth }
    public var todayX: Double { x(for: today) }
    public var todayLineX: Double { todayX + dayWidth / 2 }
    public var initialScrollX: Double { max(0, todayX - Self.todayScrollLead) }

    public func x(for date: Date) -> Double {
        Double(DayTime.days(from: rangeStart, to: date, calendar: calendar)) * dayWidth
    }

    public func barStart(start: Date?, due: Date) -> Date {
        guard let start, DayTime.days(from: start, to: due, calendar: calendar) >= 0 else { return due }
        return start
    }

    public func barFrame(start: Date?, due: Date) -> BarFrame {
        let begin = barStart(start: start, due: due)
        let days = DayTime.days(from: begin, to: due, calendar: calendar) + 1
        return BarFrame(x: x(for: begin), width: max(dayWidth, Double(days) * dayWidth))
    }

    public func dayOffset(forDrag translation: Double) -> Int {
        guard translation.isFinite else { return 0 }
        return Int((translation / dayWidth).rounded())
    }

    public var monthBlocks: [TimelineBlock] {
        var spans: [(start: Int, count: Int, date: Date)] = []
        for index in 0..<zoom.dayCount {
            let date = day(index)
            if let last = spans.last, calendar.isDate(last.date, equalTo: date, toGranularity: .month) {
                spans[spans.count - 1].count += 1
            } else {
                spans.append((index, 1, date))
            }
        }
        return spans.map { span in
            let parts = calendar.dateComponents([.year, .month], from: span.date)
            return TimelineBlock(
                x: Double(span.start) * dayWidth, width: Double(span.count) * dayWidth,
                title: "\(DateText.monthNames[(parts.month ?? 1) - 1]) \(parts.year ?? 0)", isToday: false)
        }
    }

    public var headerCells: [TimelineBlock] {
        switch zoom {
        case .week:
            (0..<zoom.dayCount).map { index in
                let date = day(index)
                return TimelineBlock(
                    x: Double(index) * dayWidth, width: dayWidth, title: "\(calendar.component(.day, from: date))",
                    isToday: calendar.isDate(date, inSameDayAs: today))
            }
        case .month:
            stride(from: 0, to: zoom.dayCount, by: 7).map { index in
                let parts = calendar.dateComponents([.month, .day], from: day(index))
                return TimelineBlock(
                    x: Double(index) * dayWidth, width: dayWidth * 7,
                    title: "\(DateText.shortMonthNames[(parts.month ?? 1) - 1]) \(parts.day ?? 1)", isToday: false)
            }
        }
    }

    public var weekendXs: [Double] {
        guard zoom == .week else { return [] }
        return (0..<zoom.dayCount).filter { [1, 7].contains(calendar.component(.weekday, from: day($0))) }
            .map { Double($0) * dayWidth }
    }

    public var weekLineXs: [Double] {
        stride(from: 0, to: zoom.dayCount, by: 7).map { Double($0) * dayWidth }
    }

    private func day(_ index: Int) -> Date {
        calendar.date(byAdding: .day, value: index, to: rangeStart) ?? rangeStart
    }
}
