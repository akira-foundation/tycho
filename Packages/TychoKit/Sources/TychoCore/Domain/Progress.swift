import Foundation

extension TaskItem {
    public var progress: Int {
        if status == .done { return 100 }
        let all = subtasks ?? []
        guard !all.isEmpty else { return status.baselineProgress }
        let done = all.filter(\.isDone).count
        return Int((Double(done) / Double(all.count) * 100).rounded())
    }

    public func dayOffset(now: Date, calendar: Calendar) -> Int? {
        guard let due else { return nil }
        let today = calendar.startOfDay(for: now)
        let dueDay = calendar.startOfDay(for: due)
        return calendar.dateComponents([.day], from: today, to: dueDay).day
    }

    public func isOverdue(now: Date, calendar: Calendar) -> Bool {
        guard status != .done, let offset = dayOffset(now: now, calendar: calendar) else { return false }
        return offset < 0
    }
}

extension Project {
    public var progress: Int {
        let all = tasks ?? []
        guard !all.isEmpty else { return 0 }
        let done = all.filter { $0.status == .done }.count
        return Int((Double(done) / Double(all.count) * 100).rounded())
    }
}
