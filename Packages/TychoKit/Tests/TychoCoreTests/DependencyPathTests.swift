import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct DependencyPathTests {
    @Test func forwardCurvesBendBetweenTheBars() {
        let curve = DependencyPath.curve(x1: 100, y1: 18, x2: 200, y2: 90)
        #expect(curve.start == TimelinePoint(x: 100, y: 18))
        #expect(curve.control1 == TimelinePoint(x: 190, y: 18))
        #expect(curve.control2 == TimelinePoint(x: 110, y: 90))
        #expect(curve.end == TimelinePoint(x: 199, y: 90))
        #expect(
            curve.arrow == [
                TimelinePoint(x: 194, y: 86.5), TimelinePoint(x: 199, y: 90), TimelinePoint(x: 194, y: 93.5),
            ])
        #expect(!curve.isDashed)
    }

    @Test func backwardCurvesAreDashed() {
        let curve = DependencyPath.curve(x1: 200, y1: 18, x2: 100, y2: 90)
        #expect(curve.control1 == TimelinePoint(x: 210, y: 18))
        #expect(curve.control2 == TimelinePoint(x: 90, y: 90))
        #expect(curve.isDashed)
    }

    @Test func curvesLinkTheEndOfTheBlockerToTheStartOfTheDependent() throws {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Website")
        let blocker = TaskItem(number: 1, title: "Wireframes")
        let blocked = TaskItem(number: 2, title: "Handoff")
        let undated = TaskItem(number: 3, title: "Someday")
        context.insert(project)
        for task in [blocker, blocked, undated] {
            context.insert(task)
            task.project = project
        }
        blocker.start = day(-1)
        blocker.due = day(1)
        blocked.start = day(2)
        blocked.due = day(5)
        blocked.blockedBy = [blocker, undated]
        let layout = TimelineLayout(zoom: .week, today: referenceNow, weekStart: .monday, calendar: utcCalendar)
        let rows = TimelineRows.build(
            tasks: [blocker, blocked, undated], grouping: .status, milestoneCount: 0, members: [], projects: [project])

        #expect(
            DependencyPath.curves(rows: rows, layout: layout) == [
                DependencyPath.curve(x1: 768, y1: 54, x2: 768, y2: 90)
            ])
    }
}
