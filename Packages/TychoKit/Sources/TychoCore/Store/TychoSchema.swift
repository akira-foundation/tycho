import Foundation
import SwiftData

public enum TychoSchema {
    public static let models: [any PersistentModel.Type] = [
        Workspace.self, Member.self, Team.self, Project.self, TaskItem.self, Subtask.self,
        Milestone.self, CalendarEvent.self, FileRecord.self,
    ]

    public static func configuration(inMemory: Bool) -> ModelConfiguration {
        ModelConfiguration(
            "Tycho",
            schema: Schema(models),
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )
    }

    public static var storeURL: URL { configuration(inMemory: false).url }

    @MainActor
    public static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        try ModelContainer(for: Schema(models), configurations: configuration(inMemory: inMemory))
    }
}
