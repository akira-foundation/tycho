import SwiftUI
import TychoCore

struct FilesControls: ViewModifier {
    @Binding var search: String
    @Binding var kind: FileKind?
    @Binding var sort: FileSort
    @Binding var layout: FileLayout
    let onUpload: () -> Void
    @Environment(\.isCompactWidth) private var isCompactWidth
    @FocusState private var isSearchFocused: Bool

    func body(content: Content) -> some View {
        content
            .searchable(text: $search, prompt: "Search Files")
            .searchFocused($isSearchFocused)
            .marksTextEditing(isFocused: isSearchFocused)
            .toolbar { items }
    }

    @ToolbarContentBuilder private var items: some ToolbarContent {
        #if os(iOS)
        if isCompactWidth {
            ToolbarItem(placement: .bottomBar) { upload }
            ToolbarSpacer(.fixed, placement: .bottomBar)
            DefaultToolbarItem(kind: .search, placement: .bottomBar)
            ToolbarSpacer(.fixed, placement: .bottomBar)
            ToolbarItem(placement: .bottomBar) { options }
        } else {
            ToolbarItemGroup {
                options
                upload
            }
        }
        #else
        ToolbarItemGroup {
            options
            upload
        }
        #endif
    }

    private var upload: some View {
        Button("Attach Files…", systemImage: "paperclip", action: onUpload)
            .accessibilityIdentifier("files.upload")
    }

    private var options: some View {
        Menu("View Options", systemImage: "ellipsis.circle") {
            Picker("View As", selection: $layout) {
                Label("Icons", systemImage: "square.grid.2x2").tag(FileLayout.grid)
                Label("List", systemImage: "list.bullet").tag(FileLayout.list)
            }
            .pickerStyle(.inline)
            Picker("Kind", selection: $kind) {
                Text("All Kinds").tag(FileKind?.none)
                ForEach(FileQuery.filterKinds) { Text($0.title).tag(FileKind?.some($0)) }
            }
            .pickerStyle(.menu)
            Picker("Sort By", selection: $sort) {
                ForEach(FileSort.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.menu)
        }
        .accessibilityIdentifier("files.options")
    }
}
