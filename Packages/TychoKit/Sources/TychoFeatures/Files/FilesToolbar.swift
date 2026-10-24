import SwiftUI
import TychoCore
import TychoDesign

struct FilesToolbar: View {
    @Binding var search: String
    @Binding var kind: FileKind?
    @Binding var sort: FileSort
    @Binding var layout: FileLayout
    let onUpload: () -> Void

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
            TychoSegmented(selection: $layout, options: [FileLayout.grid, .list]) {
                Label(
                    $0 == .grid ? "grid view" : "list view",
                    systemImage: $0 == .grid ? "square.grid.2x2" : "list.bullet"
                )
                .labelStyle(.iconOnly)
            }
            Button("Upload", systemImage: "arrow.up.doc", action: onUpload)
                .buttonStyle(.tycho(.primary, size: .sm))
        }
        .padding(.horizontal, Spacing.s4)
        .padding(.vertical, Spacing.s2)
    }
}
