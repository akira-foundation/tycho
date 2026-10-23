import Foundation

public struct DeadlineBucket: Identifiable {
    public let title: String
    public let tasks: [TaskItem]

    public var id: String { title }

    static func make(from open: [TaskItem], now: Date, calendar: Calendar) -> [DeadlineBucket] {
        let ranges: [(String, ClosedRange<Int>)] = [("Today", 0...0), ("Tomorrow", 1...1), ("This week", 2...7)]
        return ranges.map { title, range in
            let tasks =
                open
                .filter { task in task.dayOffset(now: now, calendar: calendar).map(range.contains) ?? false }
                .sorted { $0.priority.weight > $1.priority.weight }
            return DeadlineBucket(title: title, tasks: tasks)
        }
    }
}
