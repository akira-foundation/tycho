import Foundation
import SwiftUI
import TychoCore

enum TableCustomization {
    static func make(from state: TableViewState) -> TableColumnCustomization<TaskItem> {
        var customization =
            state.columns.flatMap { try? JSONDecoder().decode(TableColumnCustomization<TaskItem>.self, from: $0) }
            ?? TableColumnCustomization<TaskItem>()
        for column in TableColumnID.allCases where column.isHideable {
            customization[visibility: column.rawValue] = state.hidden.contains(column) ? .hidden : .visible
        }
        return customization
    }

    static func store(_ customization: TableColumnCustomization<TaskItem>, into state: inout TableViewState) {
        state.columns = try? JSONEncoder().encode(customization)
        state.hidden = Set(
            TableColumnID.allCases.filter { $0.isHideable && customization[visibility: $0.rawValue] == .hidden })
    }
}
