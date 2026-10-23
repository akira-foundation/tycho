import SwiftData

@MainActor
public enum DataReset {
    public static func deleteAll(in context: ModelContext) throws {
        try context.delete(model: Subtask.self)
        try context.delete(model: TaskItem.self)
        try context.delete(model: Project.self)
        try context.delete(model: Member.self)
        try context.delete(model: Team.self)
        try context.delete(model: Workspace.self)
        try context.saveOrRollback()
    }
}
