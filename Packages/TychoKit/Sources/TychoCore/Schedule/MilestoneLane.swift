import Foundation

public struct MilestoneMark: Sendable {
    public let name: String
    public let date: Date
    public let projectName: String?
    public let colorHex: UInt32?

    public init(name: String, date: Date, projectName: String?, colorHex: UInt32?) {
        self.name = name
        self.date = date
        self.projectName = projectName
        self.colorHex = colorHex
    }

    public static func marks(from milestones: [Milestone], includeProject: Bool) -> [MilestoneMark] {
        milestones
            .compactMap { milestone in
                milestone.date.map { date in
                    MilestoneMark(
                        name: milestone.name, date: date,
                        projectName: includeProject ? milestone.project?.name : nil,
                        colorHex: includeProject ? milestone.project?.color.hex : nil)
                }
            }
            .sorted { ($0.date, $0.name) < ($1.date, $1.name) }
    }
}

public struct MilestonePin: Equatable, Sendable, Identifiable {
    public let x: Double
    public let label: String?
    public let labelWidth: Double?
    public let tooltip: String
    public let colorHex: UInt32?

    public var id: Double { x }
}

public enum MilestoneLane {
    public static let minimumLabelRoom: Double = 28

    public static func pins(for marks: [MilestoneMark], layout: TimelineLayout, dateText: DateText) -> [MilestonePin] {
        let byDay = Dictionary(grouping: marks) { layout.calendar.startOfDay(for: $0.date) }
        let days = byDay.keys.sorted()
        let xs = days.map { layout.x(for: $0) + layout.dayWidth / 2 }
        return days.enumerated().compactMap { index, day in
            guard let list = byDay[day], let first = list.first else { return nil }
            let room = index + 1 < xs.count ? xs[index + 1] - xs[index] - 24 : Double.infinity
            let name = list.count > 1 ? "\(first.name) +\(list.count - 1)" : first.name
            let names = list.map { mark in mark.projectName.map { "\(mark.name) (\($0))" } ?? mark.name }
            return MilestonePin(
                x: xs[index],
                label: room >= minimumLabelRoom ? name : nil,
                labelWidth: room.isFinite ? room.rounded() : nil,
                tooltip: (names + [dateText.short(day)]).joined(separator: " · "),
                colorHex: first.colorHex
            )
        }
    }
}
