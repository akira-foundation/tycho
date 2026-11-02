import Foundation

public struct TaskViewState: Codable, Equatable, Sendable {
    public var sort: [TaskComparator] = []
    public var hidden: Set<TableColumnID>
    public var columns: Data?
    public var query: String = ""
    public var filters: [TaskFilter] = []
    public var grouping: TaskViewGrouping = .status
    public var mode: String?

    private enum CodingKeys: String, CodingKey {
        case sort
        case hidden
        case columns
        case query
        case filters
        case grouping
        case mode
    }

    public init(inProject: Bool) {
        hidden = TableColumnID.defaultHidden(inProject: inProject)
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sort = (try container.decodeIfPresent([Lossy<TaskComparator>].self, forKey: .sort) ?? []).compactMap(\.value)
        columns = try container.decodeIfPresent(Data.self, forKey: .columns)
        query = (try? container.decodeIfPresent(String.self, forKey: .query)) ?? ""
        filters = ((try? container.decodeIfPresent([Lossy<TaskFilter>].self, forKey: .filters)) ?? [])
            .compactMap(\.value)
        grouping = (try? container.decodeIfPresent(TaskViewGrouping.self, forKey: .grouping)) ?? .status
        mode = try? container.decodeIfPresent(String.self, forKey: .mode)
        let rawHidden = try container.decodeIfPresent([String].self, forKey: .hidden)
        hidden =
            rawHidden.map { Set($0.compactMap(TableColumnID.init(rawValue:))) }
            ?? TableColumnID.defaultHidden(inProject: false)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sort, forKey: .sort)
        try container.encode(TableColumnID.allCases.filter { hidden.contains($0) }, forKey: .hidden)
        try container.encodeIfPresent(columns, forKey: .columns)
        try container.encode(query, forKey: .query)
        try container.encode(filters, forKey: .filters)
        try container.encode(grouping, forKey: .grouping)
        try container.encodeIfPresent(mode, forKey: .mode)
    }

    public var viewQuery: TaskViewQuery {
        TaskViewQuery(query: query, filters: filters, sort: sort.first)
    }

    public var visibleColumns: [TableColumnID] {
        TableColumnID.allCases.filter { !hidden.contains($0) }
    }

    public mutating func setVisible(_ visible: Bool, for column: TableColumnID) {
        guard column.isHideable else { return }
        if visible {
            hidden.remove(column)
        } else {
            hidden.insert(column)
        }
    }

    public mutating func resetWidths() {
        columns = nil
    }
}

private struct Lossy<Value: Decodable>: Decodable {
    let value: Value?

    init(from decoder: any Decoder) throws {
        value = try? Value(from: decoder)
    }
}
