import SwiftUI
import TychoCore

struct ViewOptionsMenu<Layouts: View>: View {
    let model: TaskViewModel
    let showsGroup: Bool
    let showsColumns: Bool
    let layouts: Layouts

    init(model: TaskViewModel, showsGroup: Bool, showsColumns: Bool, @ViewBuilder layouts: () -> Layouts) {
        self.model = model
        self.showsGroup = showsGroup
        self.showsColumns = showsColumns
        self.layouts = layouts()
    }

    var body: some View {
        Menu("View Options", systemImage: "ellipsis.circle") {
            layouts
            Picker(selection: sortField) {
                ForEach(TaskSortField.menuOrder, id: \.self) { Text($0.title).tag($0) }
            } label: {
                Label("Sort By", systemImage: "arrow.up.arrow.down")
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("view.sort")
            Picker(selection: sortOrder) {
                Text("Ascending").tag(SortOrder.forward)
                Text("Descending").tag(SortOrder.reverse)
            } label: {
                Label("Sort Order", systemImage: "arrow.up.and.down.text.horizontal")
            }
            .pickerStyle(.menu)
            .accessibilityIdentifier("view.sort.order")
            if showsGroup {
                Picker(selection: grouping) {
                    ForEach(TaskViewGrouping.allCases, id: \.self) { Text($0.title).tag($0) }
                } label: {
                    Label("Group By", systemImage: "rectangle.3.group")
                }
                .pickerStyle(.menu)
                .accessibilityIdentifier("view.group")
            }
            if showsColumns {
                TableColumnsMenu(model: model)
            }
        }
        .accessibilityIdentifier("view.options")
    }

    private var sortField: Binding<TaskSortField> {
        Binding(get: { model.state.sort.first?.field ?? .manual }, set: { model.setSort(field: $0) })
    }

    private var sortOrder: Binding<SortOrder> {
        Binding(get: { model.state.sort.first?.order ?? .forward }, set: { model.setSortOrder($0) })
    }

    private var grouping: Binding<TaskViewGrouping> {
        Binding(get: { model.state.grouping }, set: { model.setGrouping($0) })
    }
}
