import Foundation

public struct TableViewState: Codable, Equatable, Sendable {
    public var sort: [TaskComparator] = []
    public var hidden: Set<TableColumnID>
    public var columns: Data?

    public init(inProject: Bool) {
        hidden = TableColumnID.defaultHidden(inProject: inProject)
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
