import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct SavedViewTabs: View {
    @Environment(\.modelContext) private var context
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @State private var isSaving = false
    @State private var renaming: SavedView?
    let project: Project
    let tab: ProjectTab

    var body: some View {
        HStack(spacing: Spacing.s1) {
            ForEach(SavedView.ordered(in: project)) { view in
                tabButton(view)
            }
            Button("Save view", systemImage: "plus") { isSaving = true }
                .labelStyle(.iconOnly)
                .help("Save current filters as a view")
                .accessibilityIdentifier("project.tab.saveView")
        }
        .sheet(isPresented: $isSaving) { SaveViewSheet(project: project) }
        .sheet(item: $renaming) { RenameViewSheet(view: $0) }
    }

    private func tabButton(_ view: SavedView) -> some View {
        let isSelected = tab == .savedView(view.id)
        return Button {
            router.openProject(project.id, tab: .savedView(view.id))
        } label: {
            Label(view.name, systemImage: "line.3.horizontal.decrease")
                .tychoFont(.sm, weight: isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? Token.text.color : Token.text3.color)
                .padding(.horizontal, Spacing.s2)
                .padding(.vertical, Spacing.s1)
                .background(isSelected ? Token.surface3.color : .clear, in: .rect(cornerRadius: 6))
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("project.tab.view.\(view.name)")
        .contextMenu {
            Button("Rename view", systemImage: "pencil") { renaming = view }
            Button("Delete view", systemImage: "trash", role: .destructive) {
                SavedViewFlow(context: context, router: router, toast: toast).delete(view)
            }
        }
    }
}
