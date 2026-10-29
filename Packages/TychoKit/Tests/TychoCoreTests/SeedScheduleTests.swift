import Foundation
import SwiftData
import Testing

@testable import TychoCore

@MainActor
struct SeedScheduleTests {
    private func load() throws -> (ModelContext, Workspace) {
        let context = try makeTestContext()
        return (context, try DemoSeed.load(into: context, now: referenceNow, calendar: utcCalendar))
    }

    private func task(_ key: String, in context: ModelContext) throws -> TaskItem {
        try #require(try context.fetch(FetchDescriptor<TaskItem>()).first { $0.key == key })
    }

    @Test func seedsTheOriginalCounts() throws {
        let (context, _) = try load()
        #expect(try context.fetchCount(FetchDescriptor<Milestone>()) == 10)
        #expect(try context.fetchCount(FetchDescriptor<CalendarEvent>()) == 6)
        #expect(try context.fetchCount(FetchDescriptor<FileRecord>()) == 12)
        #expect(try context.fetch(FetchDescriptor<FileRecord>()).allSatisfy { !$0.hasData && $0.data == nil })
    }

    @Test func milestonesAndEventsKeepTheirDatesAndProjects() throws {
        let (_, workspace) = try load()
        let web = try #require(workspace.projects?.first { $0.key == "WEB" })
        let milestones = (web.milestones ?? []).sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        #expect(milestones.map(\.name) == ["Wireframes signed off", "Dev handoff", "Public launch"])
        #expect(milestones.map(\.date) == [day(2), day(14), day(24)])

        let launch = try #require(workspace.projects?.first { $0.key == "LCH" })
        let sync = try #require(launch.events?.first { $0.title == "Launch sync" })
        #expect(sync.date == day(0))
        #expect(sync.time == "15:00")
        #expect(workspace.projects?.first { $0.key == "CP" }?.milestones?.isEmpty == true)
    }

    @Test func filesCarrySizesAuthorsAndTasks() throws {
        let (context, _) = try load()
        let wireframes = try task("WEB-109", in: context)
        #expect(
            Set(wireframes.orderedAttachments.map(\.name)) == ["homepage-wireframes-v3.fig", "nav-audit-findings.pdf"])

        let files = try context.fetch(FetchDescriptor<FileRecord>())
        let figma = try #require(files.first { $0.name == "homepage-wireframes-v3.fig" })
        #expect(figma.sizeText == "4.2 MB")
        #expect(figma.kind == .fig)
        #expect(figma.uploadedBy?.name == "Sarah Chen")
        #expect(figma.uploadedAt == referenceNow.addingTimeInterval(-300 * 60))
        #expect(files.first { $0.name == "nav-audit-findings.pdf" }?.sizeText == "860 KB")
        #expect(files.first { $0.name == "launch-plan.docx" }?.project?.key == "LCH")
        #expect(files.filter { $0.task != nil }.count == 2)
    }

    @Test func dependenciesFollowTheOriginal() throws {
        let (context, _) = try load()
        #expect(try task("WEB-124", in: context).orderedBlockedBy.map(\.key) == ["WEB-109", "WEB-115"])
        #expect(try task("WEB-139", in: context).orderedBlockedBy.map(\.key) == ["WEB-109"])
        #expect(try task("MOB-109", in: context).orderedBlockedBy.map(\.key) == ["MOB-106"])
        let all = try context.fetch(FetchDescriptor<TaskItem>())
        #expect(all.reduce(0) { $0 + ($1.blockedBy?.count ?? 0) } == 4)
    }
}
