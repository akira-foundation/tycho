import SwiftUI

struct ProjectTabPicker: View {
    @Binding var selection: ProjectBuiltInTab?

    var body: some View {
        #if os(macOS)
        Picker("View", selection: $selection) {
            ForEach(ProjectBuiltInTab.allCases, id: \.self) {
                SegmentLabel(title: $0.title, symbol: $0.symbol).tag(Optional($0))
            }
        }
        .pickerStyle(.segmented)
        .labelStyle(.iconOnly)
        .accessibilityIdentifier("project.tab")
        #else
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
        #endif
    }
}
