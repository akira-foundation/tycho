import SwiftData
import SwiftUI
import TychoCore

struct ProjectMenu: View {
    @Environment(\.modelContext) private var context
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    let project: Project
    let tab: ProjectTab
    let onSave: () -> Void
    let onRename: (SavedView) -> Void
    let onEdit: () -> Void

    var body: some View {
        Menu("Project Options", systemImage: "folder.badge.gearshape") {
            Section("Saved Views") {
                Button("Save View…", systemImage: "plus", action: onSave)
                if let current {
                    Button("Rename View…", systemImage: "pencil") { onRename(current) }
                    Button("Delete View", systemImage: "trash", role: .destructive) {
                        SavedViewFlow(context: context, router: router, toast: toast).delete(current)
                    }
                }
            }
            Button("Edit Project…", systemImage: "slider.horizontal.3", action: onEdit)
        }
        .accessibilityIdentifier("project.menu")
    }

    private var current: SavedView? {
        guard case .savedView(let id) = tab else { return nil }
        return SavedView.ordered(in: project).first { $0.id == id }
    }
}
