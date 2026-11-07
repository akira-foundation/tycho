import SwiftUI

struct FilterToolbarButton: View {
    let engine: TaskViewEngine
    @State private var isPresented = false

    var body: some View {
        let count = engine.model.state.filters.count
        Button("Filter", systemImage: Self.symbol(filterCount: count)) { isPresented = true }
            .badge(count)
            .popover(isPresented: $isPresented) { FilterForm(engine: engine) }
            .accessibilityIdentifier("view.filter")
    }

    static func symbol(filterCount: Int) -> String {
        filterCount > 0 ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }
}
