import Foundation
import SwiftData

@MainActor
public struct SavedViewActions {
    public static let defaultName = "Untitled view"

    private let context: ModelContext

    public init(context: ModelContext) {
        self.context = context
    }

    @discardableResult
    public func create(
        name: String, layout: SavedViewLayout, filters: [TaskFilter], in project: Project
    ) throws -> SavedView {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let view = SavedView(name: trimmed.isEmpty ? Self.defaultName : trimmed, layout: layout, filters: filters)
        view.sortOrder = Rank.appendOrder(after: SavedView.ordered(in: project))
        context.insert(view)
        view.project = project
        try context.saveOrRollback()
        return view
    }

    public func rename(_ view: SavedView, to name: String) throws {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        view.name = trimmed
        try context.saveOrRollback()
    }

    public func delete(_ view: SavedView) throws {
        context.delete(view)
        try context.saveOrRollback()
    }
}
