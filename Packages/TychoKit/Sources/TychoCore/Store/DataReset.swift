import Foundation
import SwiftData

@MainActor
public enum DataReset {
    public static func deleteAll(in context: ModelContext) throws {
        try context.delete(model: FileRecord.self)
        try context.delete(model: CalendarEvent.self)
        try context.delete(model: Milestone.self)
        try context.delete(model: Subtask.self)
        try context.delete(model: TaskItem.self)
        try context.delete(model: Project.self)
        try context.delete(model: Member.self)
        try context.delete(model: Team.self)
        try context.delete(model: Workspace.self)
        try context.saveOrRollback()
    }

    public static func reloadDemo(in context: ModelContext, now: Date, calendar: Calendar) throws {
        let ownerName = try context.fetch(FetchDescriptor<Member>()).first { $0.isMe }?.name ?? ""
        try deleteAll(in: context)
        try DemoSeed.load(into: context, now: now, calendar: calendar, ownerName: ownerName)
    }
}
