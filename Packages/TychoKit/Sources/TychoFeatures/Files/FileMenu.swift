import SwiftUI

struct FileMenuActions {
    let preview: () -> Void
    let rename: () -> Void
    let copyLink: () -> Void
    let duplicate: () -> Void
    let delete: () -> Void
}

struct FileMenuItems: View {
    let actions: FileMenuActions

    var body: some View {
        Button("Preview", systemImage: "eye", action: actions.preview)
        Button("Rename", systemImage: "pencil", action: actions.rename)
        Button("Copy link", systemImage: "link", action: actions.copyLink)
        Button("Duplicate", systemImage: "doc.on.doc", action: actions.duplicate)
        Divider()
        Button("Delete", systemImage: "trash", role: .destructive, action: actions.delete)
    }
}

struct FileMenuButton: View {
    let actions: FileMenuActions

    var body: some View {
        Menu {
            FileMenuItems(actions: actions)
        } label: {
            Image(systemName: "ellipsis")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.hidden)
        .fixedSize()
        .accessibilityLabel("File options")
    }
}
