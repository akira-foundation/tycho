import Foundation

public struct TimelinePoint: Equatable, Sendable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

public struct DependencyCurve: Equatable, Sendable {
    public let start: TimelinePoint
    public let control1: TimelinePoint
    public let control2: TimelinePoint
    public let end: TimelinePoint
    public let arrow: [TimelinePoint]
    public let isDashed: Bool
}

public enum DependencyPath {
    public static func curve(x1: Double, y1: Double, x2: Double, y2: Double) -> DependencyCurve {
        DependencyCurve(
            start: TimelinePoint(x: x1, y: y1),
            control1: TimelinePoint(x: max(x1 + 10, x2 - 10), y: y1),
            control2: TimelinePoint(x: min(x1 + 10, x2 - 10), y: y2),
            end: TimelinePoint(x: x2 - 1, y: y2),
            arrow: [
                TimelinePoint(x: x2 - 6, y: y2 - 3.5), TimelinePoint(x: x2 - 1, y: y2),
                TimelinePoint(x: x2 - 6, y: y2 + 3.5),
            ],
            isDashed: x2 < x1
        )
    }

    public static func curves(rows: [TimelineRow], layout: TimelineLayout) -> [DependencyCurve] {
        let centers = TimelineRows.centers(of: rows)
        return rows.flatMap { row -> [DependencyCurve] in
            guard case .task(let task) = row, let due = task.due, let y2 = centers[task.id] else { return [] }
            let x2 = layout.x(for: layout.barStart(start: task.start, due: due))
            return task.orderedBlockedBy.compactMap { dependency in
                guard let y1 = centers[dependency.id], let dependencyDue = dependency.due else { return nil }
                return curve(x1: layout.x(for: dependencyDue) + layout.dayWidth, y1: y1, x2: x2, y2: y2)
            }
        }
    }
}
