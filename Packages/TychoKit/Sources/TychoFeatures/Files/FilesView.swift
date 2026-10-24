import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct FilesView: View {
    @Environment(\.modelContext) private var context
    @Environment(ToastCenter.self) private var toast
    let project: Project
    @State private var search = ""
    @State private var kind: FileKind?
    @State private var sort = FileSort.newest
    @AppStorage("files.layout") private var layout = FileLayout.grid
    @State private var previewing: FileRecord?
    @State private var renaming: FileRecord?
    @State private var renameText = ""
    @State private var deleting: FileRecord?

    var body: some View {
        let files = FileQuery.apply(project.files ?? [], search: search, kind: kind, sort: sort)
        VStack(spacing: 0) {
            FilesToolbar(search: $search, kind: $kind, sort: $sort, layout: $layout)
            Divider()
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.s4) {
                    content(files)
                }
                .padding(Spacing.s6)
            }
        }
        .background(Token.bg.color)
        .sheet(item: $previewing) { FilePreviewSheet(file: $0) }
        .alert("Rename file", isPresented: isRenaming) {
            TextField("File name", text: $renameText)
            Button("Rename", action: commitRename)
            Button("Cancel", role: .cancel) { renaming = nil }
        }
        .confirmationDialog("Delete file?", isPresented: isDeleting, presenting: deleting) { file in
            Button("Delete file", role: .destructive) { delete(file) }
        } message: { file in
            Text(FileMessages.deleteMessage(file))
        }
    }

    @ViewBuilder private func content(_ files: [FileRecord]) -> some View {
        switch (files.isEmpty, layout) {
        case (true, _): emptyState
        case (false, .grid): FileGrid(files: files, actions: actions)
        case (false, .list): FileList(files: files, actions: actions)
        }
    }

    private var emptyState: some View {
        let filtering = FileQuery.isFiltering(search: search, kind: kind)
        return EmptyState(
            title: filtering ? "No results found" : "No files yet",
            symbol: filtering ? "magnifyingglass" : "folder",
            message: filtering
                ? "No files match your search."
                : "Upload designs, documents, and assets to share them with the project."
        )
        .frame(minHeight: 320)
    }

    private var isRenaming: Binding<Bool> {
        Binding(get: { renaming != nil }, set: { if !$0 { renaming = nil } })
    }

    private var isDeleting: Binding<Bool> {
        Binding(get: { deleting != nil }, set: { if !$0 { deleting = nil } })
    }

    private func actions(_ file: FileRecord) -> FileMenuActions {
        FileMenuActions(
            preview: { previewing = file },
            rename: {
                renameText = file.name
                renaming = file
            },
            copyLink: {
                Pasteboard.copy(FileMessages.link(file))
                toast.show("Link copied")
            },
            duplicate: { duplicate(file) },
            delete: { deleting = file }
        )
    }

    private func commitRename() {
        guard let file = renaming else { return }
        renaming = nil
        toast.perform { try FileActions(context: context).rename(file, to: renameText) }
    }

    private func duplicate(_ file: FileRecord) {
        toast.perform {
            try FileActions(context: context).duplicate(file, by: project.workspace?.me)
            toast.show("File duplicated")
        }
    }

    private func delete(_ file: FileRecord) {
        let name = file.name
        toast.perform {
            try FileActions(context: context).delete(file)
            toast.show("Deleted \(name)")
        }
    }
}
