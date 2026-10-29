import SwiftUI
import TychoCore

struct TableColumnsMenu: View {
    let model: TaskViewModel

    var body: some View {
        let hidden = model.state.hidden
        Menu("Columns", systemImage: "tablecells") {
            Section("Visible columns") {
                ForEach(TableColumnID.allCases.filter(\.isHideable)) { column in
                    Toggle(
                        column.title,
                        isOn: Binding(
                            get: { !hidden.contains(column) },
                            set: { model.setVisible($0, for: column) }))
                }
            }
            Button("Reset widths") { model.resetWidths() }
        }
        .fixedSize()
        .accessibilityIdentifier("table.columns")
    }
}
