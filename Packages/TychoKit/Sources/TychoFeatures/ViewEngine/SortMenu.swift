import SwiftUI
import TychoCore
import TychoDesign

struct SortMenu: View {
    let model: TaskViewModel

    var body: some View {
        let current = model.state.sort.first
        VStack(alignment: .leading, spacing: Spacing.s2) {
            Text("Sort by")
                .tychoFont(.xs, weight: .semibold)
                .foregroundStyle(Token.text3.color)
            ForEach(TaskSortField.menuOrder, id: \.self) { field in
                Button {
                    model.setSort(field: field)
                } label: {
                    HStack {
                        Text(field.title)
                        Spacer()
                        if (current?.field ?? .manual) == field {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("view.sort.\(field.rawValue)")
            }
            Divider()
            Picker(
                "Direction",
                selection: Binding(
                    get: { current?.order ?? .forward },
                    set: { model.setSortOrder($0) })
            ) {
                Text("Ascending").tag(SortOrder.forward)
                Text("Descending").tag(SortOrder.reverse)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .accessibilityIdentifier("view.sort.order")
        }
        .padding(Spacing.s3)
        .frame(width: 220)
    }
}
