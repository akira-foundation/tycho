import SwiftUI
import TychoCore

struct TableColumnsMenu: View {
    @Binding var state: TableViewState

    var body: some View {
        Menu("Columns", systemImage: "tablecells") {
            Section("Visible columns") {
                ForEach(TableColumnID.allCases.filter(\.isHideable)) { column in
                    Toggle(
                        column.title,
                        isOn: Binding(
                            get: { !state.hidden.contains(column) },
                            set: { state.setVisible($0, for: column) }))
                }
            }
            Button("Reset widths") { state.resetWidths() }
        }
        .fixedSize()
        .accessibilityIdentifier("table.columns")
    }
}
