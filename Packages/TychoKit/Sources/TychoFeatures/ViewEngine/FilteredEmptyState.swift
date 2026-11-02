import SwiftUI
import TychoDesign

struct FilteredEmptyState: View {
    let onClear: () -> Void

    static func applies(source: Int, visible: Int) -> Bool {
        source > 0 && visible == 0
    }

    var body: some View {
        VStack(spacing: Spacing.s3) {
            EmptyState(
                title: "No results found", symbol: "line.3.horizontal.decrease",
                message: "No tasks match these filters.")
            Button("Clear filters", action: onClear)
                .buttonStyle(.tycho(.secondary))
                .accessibilityIdentifier("view.clearFilters")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
