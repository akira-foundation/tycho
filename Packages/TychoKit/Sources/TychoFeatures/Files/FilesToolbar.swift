import SwiftUI
import TychoCore
import TychoDesign

struct FilesToolbar: View {
    @Binding var search: String
    @Binding var kind: FileKind?
    @Binding var sort: FileSort
    @Binding var layout: FileLayout

    var body: some View {
        HStack(spacing: Spacing.s2) {
            TextField("Search files", text: $search)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 220)
                .accessibilityIdentifier("files.search")
            Picker("Filter by type", selection: $kind) {
                Text("All types").tag(FileKind?.none)
                ForEach(FileQuery.filterKinds) { Text($0.title).tag(FileKind?.some($0)) }
            }
            .labelsHidden()
            .fixedSize()
            Picker("Sort", selection: $sort) {
                ForEach(FileSort.allCases) { Text($0.title).tag($0) }
            }
            .labelsHidden()
            .fixedSize()
            Spacer()
            Picker("Layout", selection: $layout) {
                Label("grid view", systemImage: "square.grid.2x2").labelStyle(.iconOnly).tag(FileLayout.grid)
                Label("list view", systemImage: "list.bullet").labelStyle(.iconOnly).tag(FileLayout.list)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .fixedSize()
        }
        .padding(.horizontal, Spacing.s4)
        .padding(.vertical, Spacing.s2)
    }
}
