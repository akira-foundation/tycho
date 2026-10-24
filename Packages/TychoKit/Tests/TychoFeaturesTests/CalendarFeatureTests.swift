import Foundation
import SwiftData
import Testing

@testable import TychoCore
@testable import TychoFeatures

@MainActor
struct CalendarFeatureTests {
    private let utc: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
    private let now = Date(timeIntervalSince1970: 1_791_892_800)

    private func noon(_ offset: Int) -> Date { utc.date(byAdding: .day, value: offset, to: now)! }

    private func setUp() throws -> (ModelContext, TaskItem) {
        let context = ModelContext(try TychoSchema.makeContainer(inMemory: true))
        let project = Project(key: "WEB", name: "Website")
        context.insert(project)
        let task = try TaskActions(context: context).create(TaskDraft(title: "Wireframes"), in: project)
        task.start = noon(-1)
        task.due = noon(1)
        return (context, task)
    }

    @Test func droppingOnAnotherDayReschedulesAndAnnouncesIt() throws {
        let (context, task) = try setUp()
        let toast = ToastCenter()
        let text = DateText(format: .monthDay, now: now, calendar: utc)

        let handled = CalendarDropHandler(context: context).announceDrop(
            [task.id], on: noon(4), in: [task], toast: toast, dateText: text)

        #expect(handled)
        #expect(task.due == noon(4))
        #expect(task.start == noon(2))
        #expect(toast.message == "Rescheduled “Wireframes” to Oct 17")
    }

    @Test func droppingNormalisesToNoonInTheCalendarOfTheDateText() throws {
        var kiritimati = Calendar(identifier: .gregorian)
        kiritimati.timeZone = TimeZone(identifier: "Pacific/Kiritimati")!
        let (context, task) = try setUp()
        task.start = nil
        task.due = nil
        let target = kiritimati.date(from: DateComponents(year: 2026, month: 10, day: 20, hour: 3))!
        let text = DateText(format: .monthDay, now: now, calendar: kiritimati)

        _ = CalendarDropHandler(context: context).announceDrop(
            [task.id], on: target, in: [task], toast: ToastCenter(), dateText: text)

        let due = try #require(task.due)
        #expect(kiritimati.dateComponents([.day, .hour], from: due) == DateComponents(day: 20, hour: 12))
    }

    @Test func droppingOnTheSameDayOrAnUnknownTaskDoesNothing() throws {
        let (context, task) = try setUp()
        let handler = CalendarDropHandler(context: context)
        #expect(try handler.drop([task.id], on: noon(1), in: [task], calendar: utc) == nil)
        #expect(try handler.drop([UUID()], on: noon(3), in: [task], calendar: utc) == nil)
        #expect(task.due == noon(1))
    }

    @Test func messagesMatchTheOriginal() {
        let text = DateText(format: .monthDay, now: now, calendar: utc)
        #expect(ScheduleMessages.rescheduled("Audit", to: noon(2), dateText: text) == "Rescheduled “Audit” to Oct 15")
        #expect(ScheduleMessages.moved("Audit", days: 1) == "Moved “Audit” 1 day later")
        #expect(ScheduleMessages.moved("Audit", days: -3) == "Moved “Audit” 3 days earlier")
    }

    @Test func theLegendListsEachProjectOnceInSidebarOrder() throws {
        let context = ModelContext(try TychoSchema.makeContainer(inMemory: true))
        let web = Project(key: "WEB", name: "Website")
        let mobile = Project(key: "MOB", name: "Mobile")
        web.sortOrder = 2
        mobile.sortOrder = 1
        context.insert(web)
        context.insert(mobile)
        let actions = TaskActions(context: context)
        let tasks = try [
            actions.create(TaskDraft(title: "A"), in: web), actions.create(TaskDraft(title: "B"), in: mobile),
            actions.create(TaskDraft(title: "C"), in: web),
        ]
        #expect(CalendarLegend.projects(in: tasks).map(\.key) == ["MOB", "WEB"])
    }

    @Test func weekColumnsNameTheirWeekday() {
        let cells = CalendarGrid.week(containing: now, weekStart: .sunday, today: now, calendar: utc)
        #expect(cells.map(CalendarWeekView.weekdayName) == ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"])
    }
}
