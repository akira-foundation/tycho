import SwiftUI
import TychoCore

extension TaskViewModel {
    var columnCustomization: TableColumnCustomization<TaskItem> {
        TableCustomization.make(from: state)
    }

    func setColumnCustomization(_ customization: TableColumnCustomization<TaskItem>) {
        var next = state
        TableCustomization.store(customization, into: &next)
        state = next
    }

    func setVisible(_ visible: Bool, for column: TableColumnID) {
        var next = state
        next.setVisible(visible, for: column)
        state = next
    }

    func resetWidths() {
        var next = state
        next.resetWidths()
        state = next
    }
}
