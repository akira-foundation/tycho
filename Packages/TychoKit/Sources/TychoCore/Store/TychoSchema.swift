import SwiftData

public enum TychoSchema {
    public static let models: [any PersistentModel.Type] = [
        Workspace.self, Member.self, Team.self, Project.self, TaskItem.self, Subtask.self,
    ]

    @MainActor
    public static func makeContainer(inMemory: Bool) throws -> ModelContainer {
        let schema = Schema(models)
        let configuration = ModelConfiguration(
            "Tycho",
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: .none
        )
        return try ModelContainer(for: schema, configurations: configuration)
    }
}
