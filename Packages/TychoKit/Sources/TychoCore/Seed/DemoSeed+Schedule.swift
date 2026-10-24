import Foundation
import SwiftData

extension DemoSeed {
    static func loadSchedule(
        into context: ModelContext,
        projects: [String: Project],
        members: [String: Member],
        tasks: [TaskItem],
        now: Date,
        date: (Int) -> Date
    ) {
        for seed in DemoSeedData.milestones {
            let milestone = Milestone(name: seed.name, date: date(seed.day))
            context.insert(milestone)
            milestone.project = projects[seed.project]
        }
        for seed in DemoSeedData.events {
            let event = CalendarEvent(title: seed.title, date: date(seed.day), time: seed.time)
            context.insert(event)
            event.project = projects[seed.project]
        }
        for seed in DemoSeedData.files {
            let file = FileRecord(
                name: seed.name, byteCount: seed.bytes,
                uploadedAt: now.addingTimeInterval(-Double(seed.minutesAgo) * 60))
            context.insert(file)
            file.project = projects[seed.project]
            file.uploadedBy = members[seed.by]
            file.task = seed.task.map { tasks[$0 - 1] }
        }
        for (index, seed) in DemoSeedData.tasks.enumerated() where !seed.blockedBy.isEmpty {
            tasks[index].blockedBy = seed.blockedBy.map { tasks[$0 - 1] }
        }
    }
}
