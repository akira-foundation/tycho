import SwiftUI
import TychoCore
import TychoDesign

struct TaskViewToolbar<Trailing: View>: View {
    let model: TaskViewModel
    let showsGroup: Bool
    let showsColumns: Bool
    let members: [Member]
    let projects: [Project]
    let onFilter: () -> Void
    let trailing: Trailing

    @State private var showingFilter = false
    @State private var showingSort = false
    @State private var showingGroup = false

    init(
        model: TaskViewModel, showsGroup: Bool, showsColumns: Bool, members: [Member] = [], projects: [Project] = [],
        onFilter: @escaping () -> Void = {}, @ViewBuilder trailing: () -> Trailing
    ) {
        self.model = model
        self.showsGroup = showsGroup
        self.showsColumns = showsColumns
        self.members = members
        self.projects = projects
        self.onFilter = onFilter
        self.trailing = trailing()
    }

    var body: some View {
        let state = model.state
        HStack(spacing: Spacing.s2) {
            TextField(
                "Search tasks",
                text: Binding(get: { state.query }, set: { model.setQuery($0) })
            )
            .marksTextEditing()
            .textFieldStyle(.roundedBorder)
            .frame(maxWidth: 220)
            .accessibilityIdentifier("view.search")
            filterButton(count: state.filters.count)
            Button("Sort: \(sortTitle(state))", systemImage: "arrow.up.arrow.down") { showingSort = true }
                .buttonStyle(.tycho(.secondary, size: .sm))
                .popover(isPresented: $showingSort) { SortMenu(model: model) }
                .accessibilityIdentifier("view.sort")
            if showsGroup {
                Button("Group: \(state.grouping.title)", systemImage: "rectangle.3.group") { showingGroup = true }
                    .buttonStyle(.tycho(.secondary, size: .sm))
                    .popover(isPresented: $showingGroup) { GroupMenu(model: model) }
                    .accessibilityIdentifier("view.group")
            }
            if showsColumns {
                TableColumnsMenu(model: model)
            }
            Spacer()
            trailing
        }
        .padding(.horizontal, Spacing.s4)
        .padding(.vertical, Spacing.s2)
    }

    private func sortTitle(_ state: TaskViewState) -> String {
        (state.sort.first?.field ?? .manual).title
    }

    private func filterButton(count: Int) -> some View {
        Button {
            showingFilter = true
            onFilter()
        } label: {
            HStack(spacing: Spacing.s1) {
                Image(systemName: "line.3.horizontal.decrease")
                Text("Filter")
                if count > 0 {
                    Text("\(count)")
                        .tychoFont(.xxs, weight: .semibold)
                        .foregroundStyle(Token.onAccent.color)
                        .padding(.horizontal, 5)
                        .background(Color.accentColor, in: Capsule())
                }
            }
        }
        .buttonStyle(.tycho(.secondary, size: .sm))
        .popover(isPresented: $showingFilter) {
            FilterBuilder(model: model, members: members, projects: projects)
        }
        .onChange(of: showingFilter) { _, open in
            if !open { model.editingFilterIndex = nil }
        }
        .accessibilityIdentifier("view.filter")
    }
}
