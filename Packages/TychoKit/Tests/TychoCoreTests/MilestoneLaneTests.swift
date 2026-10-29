import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct MilestoneLaneTests {
    private let layout = TimelineLayout(zoom: .week, today: referenceNow, weekStart: .monday, calendar: utcCalendar)
    private let text = DateText(format: .monthDay, now: referenceNow, calendar: utcCalendar)

    @Test func sameDayMilestonesMergeAndLabelsNeedRoom() {
        let marks = [
            MilestoneMark(name: "A", date: day(2), projectName: nil, colorHex: nil),
            MilestoneMark(name: "B", date: day(2, hour: 18), projectName: nil, colorHex: nil),
            MilestoneMark(name: "C", date: day(10), projectName: nil, colorHex: nil),
            MilestoneMark(name: "D", date: day(11), projectName: nil, colorHex: nil),
        ]
        let pins = MilestoneLane.pins(for: marks, layout: layout, dateText: text)

        #expect(pins.map(\.x) == [784, 1040, 1072])
        #expect(pins.map(\.label) == ["A +1", nil, "D"])
        #expect(pins.map(\.labelWidth) == [232, 8, nil])
        #expect(pins[0].tooltip == "A · B · Oct 15")
    }

    @Test func workspaceMarksNameAndColorTheirProject() throws {
        let context = try makeTestContext()
        let project = Project(key: "WEB", name: "Website")
        project.color = .teal
        let later = Milestone(name: "Launch", date: day(5))
        let sooner = Milestone(name: "Handoff", date: day(2))
        let undated = Milestone(name: "Someday", date: nil)
        context.insert(project)
        for milestone in [later, sooner, undated] {
            context.insert(milestone)
            milestone.project = project
        }

        let marks = MilestoneMark.marks(from: [later, sooner, undated], includeProject: true)
        #expect(marks.map(\.name) == ["Handoff", "Launch"])
        #expect(marks.first?.colorHex == ProjectColor.teal.hex)
        #expect(
            MilestoneLane.pins(for: marks, layout: layout, dateText: text).first?.tooltip
                == "Handoff (Website) · Oct 15")
        #expect(MilestoneMark.marks(from: [later], includeProject: false).first?.projectName == nil)
    }
}
