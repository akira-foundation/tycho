import SwiftUI
import TychoCore

struct TaskViewEngine {
    let model: TaskViewModel
    let members: [Member]
    let projects: [Project]
}

struct TaskViewControls<Layouts: View>: ViewModifier {
    let engine: TaskViewEngine
    let showsGroup: Bool
    let showsColumns: Bool
    let layouts: Layouts
    @Environment(\.isCompactWidth) private var isCompactWidth
    @FocusState private var isSearching: Bool

    func body(content: Content) -> some View {
        let model = engine.model
        content
            .searchable(
                text: Binding(get: { model.state.query }, set: { model.setQuery($0) }), prompt: "Search Tasks"
            )
            .searchFocused($isSearching)
            .marksTextEditing(isFocused: isSearching)
            .toolbar { items }
    }

    @ToolbarContentBuilder private var items: some ToolbarContent {
        #if os(iOS)
        if isCompactWidth {
            ToolbarItem(placement: .bottomBar) { FilterToolbarButton(engine: engine) }
            ToolbarSpacer(.fixed, placement: .bottomBar)
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.fixed, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) { viewOptions }
        } else {
            ToolbarItemGroup {
                FilterToolbarButton(engine: engine)
                viewOptions
            }
        }
        #else
        ToolbarItemGroup {
            FilterToolbarButton(engine: engine)
            viewOptions
        }
        #endif
    }

    private var viewOptions: some View {
        ViewOptionsMenu(model: engine.model, showsGroup: showsGroup, showsColumns: showsColumns) { layouts }
    }
}

extension View {
    func taskViewControls<Layouts: View>(
        _ engine: TaskViewEngine, showsGroup: Bool = false, showsColumns: Bool = false,
        @ViewBuilder layouts: () -> Layouts = { EmptyView() }
    ) -> some View {
        modifier(
            TaskViewControls(engine: engine, showsGroup: showsGroup, showsColumns: showsColumns, layouts: layouts()))
    }
}
