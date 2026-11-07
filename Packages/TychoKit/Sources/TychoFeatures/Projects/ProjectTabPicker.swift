import SwiftUI

struct ProjectTabPicker: View {
    @Binding var selection: ProjectBuiltInTab?
    @Environment(\.isCompactWidth) private var isCompact

    var body: some View {
        if isCompact {
            Menu {
                Picker("View", selection: $selection) {
                    ForEach(ProjectBuiltInTab.allCases, id: \.self) {
                        Label($0.title, systemImage: $0.symbol).tag(Optional($0))
                    }
                }
                .pickerStyle(.inline)
            } label: {
                Label(selection?.title ?? "View", systemImage: selection?.symbol ?? "square.stack")
            }
            .accessibilityIdentifier("project.tab")
        } else {
            Picker("View", selection: $selection) {
                ForEach(ProjectBuiltInTab.allCases, id: \.self) { Text($0.title).tag(Optional($0)) }
            }
            .pickerStyle(.segmented)
            .accessibilityIdentifier("project.tab")
        }
    }
}
