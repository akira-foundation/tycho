import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct SeedTests {
    @Test func demoSeedReproducesTheOriginalWorkspace() throws {
        let context = try makeTestContext()
        let workspace = try DemoSeed.load(into: context, now: referenceNow, calendar: utcCalendar)

        #expect(workspace.name == "Gr8r Studio")
        #expect(try context.fetchCount(FetchDescriptor<Member>()) == 8)
        #expect(try context.fetchCount(FetchDescriptor<Team>()) == 4)
        #expect(try context.fetchCount(FetchDescriptor<Project>()) == 7)
        #expect(try context.fetchCount(FetchDescriptor<TaskItem>()) == 49)
        #expect(try context.fetchCount(FetchDescriptor<Subtask>()) == 16)

        let projects = (workspace.projects ?? []).sorted { $0.sortOrder < $1.sortOrder }
        #expect(projects.map(\.key) == ["WEB", "MOB", "MKT", "LCH", "DS", "CP", "MW"])
        #expect(projects.map { $0.tasks?.count ?? 0 } == [18, 9, 7, 6, 6, 1, 2])

        let me = try #require(workspace.me)
        #expect(me.name == "Tanjim Islam")
        #expect((workspace.members ?? []).filter(\.isMe).count == 1)
    }

    @Test func demoSeedNamesTheMemberAfterTheTypedOwner() throws {
        let context = try makeTestContext()
        let workspace = try DemoSeed.load(
            into: context, now: referenceNow, calendar: utcCalendar, ownerName: "  Ilda Tavares  ")

        let me = try #require(workspace.me)
        #expect(me.name == "Ilda Tavares")
        #expect(me.initials == "IT")
        #expect(!(workspace.members ?? []).contains { $0.name == "Tanjim Islam" })
    }

    @Test func demoSeedKeepsTheSeedNameForABlankOwner() throws {
        let context = try makeTestContext()
        let workspace = try DemoSeed.load(into: context, now: referenceNow, calendar: utcCalendar, ownerName: "  ")

        #expect(try #require(workspace.me).name == "Tanjim Islam")
    }

    @Test func demoTasksCarryKeysDatesAndCompletion() throws {
        let context = try makeTestContext()
        let workspace = try DemoSeed.load(into: context, now: referenceNow, calendar: utcCalendar)
        let web = try #require(workspace.projects?.first { $0.key == "WEB" })
        let tasks = (web.tasks ?? []).sorted { $0.number < $1.number }

        #expect(tasks.first?.key == "WEB-103")
        #expect(tasks.first?.title == "Audit existing navigation")
        #expect(tasks.last?.key == "WEB-154")
        #expect(web.nextTaskNumber == 155)

        let wireframes = try #require(tasks.first { $0.title == "Create homepage wireframes" })
        #expect(wireframes.status == .review)
        #expect(wireframes.assignee?.name == "Sarah Chen")
        #expect(wireframes.isFavorite)
        #expect(wireframes.orderedSubtasks.map(\.isDone) == [true, true, true, false])
        #expect(wireframes.due == day(1))
        #expect(wireframes.start == day(-6))
        #expect(wireframes.notes.contains("**desktop, tablet, and mobile**"))

        let allTasks = try context.fetch(FetchDescriptor<TaskItem>())
        #expect(allTasks.allSatisfy { $0.project != nil && $0.assignee != nil })
        #expect(allTasks.filter { $0.status == .done }.allSatisfy { $0.completedAt != nil })
        #expect(allTasks.filter { $0.status != .done }.allSatisfy { $0.completedAt == nil })
    }

    @Test func emptySeedCreatesOnlyTheOwner() throws {
        let context = try makeTestContext()
        let workspace = try EmptySeed.load(into: context, ownerName: "  Kid  ")
        #expect(workspace.me?.name == "Kid")
        #expect(try context.fetchCount(FetchDescriptor<Project>()) == 0)
    }

    @Test func emptySeedRejectsABlankName() throws {
        let context = try makeTestContext()
        #expect(throws: ValidationError.emptyName) { try EmptySeed.load(into: context, ownerName: " ") }
    }

    @Test func deleteAllEmptiesEveryModel() throws {
        let context = try makeTestContext()
        try DemoSeed.load(into: context, now: referenceNow, calendar: utcCalendar)
        try DataReset.deleteAll(in: context)
        for count in [
            try context.fetchCount(FetchDescriptor<Workspace>()),
            try context.fetchCount(FetchDescriptor<Member>()),
            try context.fetchCount(FetchDescriptor<Team>()),
            try context.fetchCount(FetchDescriptor<Project>()),
            try context.fetchCount(FetchDescriptor<TaskItem>()),
            try context.fetchCount(FetchDescriptor<Subtask>()),
        ] {
            #expect(count == 0)
        }
    }

    @Test func reloadDemoRestoresTheOriginalWorkspace() throws {
        let context = try makeTestContext()
        let workspace = try DemoSeed.load(into: context, now: referenceNow, calendar: utcCalendar)
        let web = try #require(workspace.projects?.first { $0.key == "WEB" })
        context.delete(web)
        try context.save()

        try DataReset.reloadDemo(in: context, now: referenceNow, calendar: utcCalendar)

        #expect(try context.fetchCount(FetchDescriptor<Workspace>()) == 1)
        #expect(try context.fetchCount(FetchDescriptor<Project>()) == 7)
        #expect(try context.fetchCount(FetchDescriptor<TaskItem>()) == 49)
    }

    @Test func deleteAllAlsoEmptiesTheScheduleAndFiles() throws {
        let context = try makeTestContext()
        context.insert(Milestone(name: "Launch", date: day(1)))
        context.insert(CalendarEvent(title: "Review", date: day(1), time: "10:00"))
        context.insert(FileRecord(name: "brief.pdf", byteCount: 1, uploadedAt: referenceNow))
        try context.save()

        try DataReset.deleteAll(in: context)

        #expect(try context.fetchCount(FetchDescriptor<Milestone>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<CalendarEvent>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<FileRecord>()) == 0)
    }
}
