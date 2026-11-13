import SwiftUI
import TychoCore

struct BoardColumnsMenu: View {
    let model: TaskViewModel

    var body: some View {
        let visible = model.state.visibleStatuses
        Menu("Columns", systemImage: "rectangle.split.3x1") {
            Section("Visible Columns") {
                ForEach(TaskStatus.allCases) { status in
                    Toggle(
                        status.title,
                        isOn: Binding(
                            get: { visible.contains(status) },
                            set: { model.setVisible($0, for: status) })
                    )
                    .disabled(visible == [status])
                }
            }
        }
        .accessibilityIdentifier("board.columns")
    }
}
