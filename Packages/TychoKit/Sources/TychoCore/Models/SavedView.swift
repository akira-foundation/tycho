import Foundation
import SwiftData

public enum SavedViewLayout: String, Codable, CaseIterable, Sendable {
    case list
    case board
    case table

    public var title: String {
        switch self {
        case .list: "List"
        case .board: "Board"
        case .table: "Table"
        }
    }
}

@Model
public final class SavedView {
    public var id: UUID = UUID()
    public var name: String = ""
    public var layoutRaw: String = SavedViewLayout.list.rawValue
    public var filtersData: Data = Data()
    public var sortOrder: Double = 0
    public var createdAt: Date = Date.now
    public var project: Project?

    public init(name: String, layout: SavedViewLayout, filters: [TaskFilter] = []) {
        self.name = name
        self.layoutRaw = layout.rawValue
        self.filtersData = Self.encode(filters)
    }

    public var layout: SavedViewLayout {
        get { SavedViewLayout(rawValue: layoutRaw) ?? .list }
        set { layoutRaw = newValue.rawValue }
    }

    public var filters: [TaskFilter] {
        get { (try? JSONDecoder().decode([TaskFilter].self, from: filtersData)) ?? [] }
        set { filtersData = Self.encode(newValue) }
    }

    public static func ordered(in project: Project) -> [SavedView] {
        (project.savedViews ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    private static func encode(_ filters: [TaskFilter]) -> Data {
        (try? JSONEncoder().encode(filters)) ?? Data()
    }
}

extension SavedView: Rankable {}
