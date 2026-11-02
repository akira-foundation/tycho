import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct SavedViewTabs: View {
    @Environment(\.modelContext) private var context
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    let project: Project
    let tab: ProjectTab
    let onSave: () -> Void
    let onRename: (SavedView) -> Void

    var body: some View {
        HStack(spacing: Spacing.s1) {
            ForEach(SavedView.ordered(in: project)) { view in
                tabButton(view)
            }
            Button("Save view", systemImage: "plus", action: onSave)
                .labelStyle(.iconOnly)
                .help("Save current filters as a view")
                .accessibilityIdentifier("project.tab.saveView")
        }
    }

    private func tabButton(_ view: SavedView) -> some View {
        let isSelected = tab == .savedView(view.id)
        return HStack(spacing: 0) {
            Button {
                router.openProject(project.id, tab: .savedView(view.id))
            } label: {
                Label(view.name, systemImage: "line.3.horizontal.decrease")
                    .tychoFont(.sm, weight: isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? Token.text.color : Token.text3.color)
                    .padding(.leading, Spacing.s2)
                    .padding(.trailing, isSelected ? 0 : Spacing.s2)
                    .padding(.vertical, Spacing.s1)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityIdentifier("project.tab.view.\(view.name)")
            .contextMenu { actions(for: view) }
            if isSelected {
                Menu {
                    actions(for: view)
                } label: {
                    Image(systemName: "ellipsis").tychoFont(.xs).foregroundStyle(Token.text3.color)
                }
                .menuStyle(.button)
                .buttonStyle(.plain)
                .menuIndicator(.hidden)
                .fixedSize()
                .padding(.horizontal, Spacing.s1)
                .accessibilityLabel("View options")
                .accessibilityIdentifier("project.tab.view.menu")
            }
        }
        .background(isSelected ? Token.surface3.color : .clear, in: .rect(cornerRadius: 6))
    }

    @ViewBuilder private func actions(for view: SavedView) -> some View {
        Button("Rename view", systemImage: "pencil") { onRename(view) }
        Button("Delete view", systemImage: "trash", role: .destructive) {
            SavedViewFlow(context: context, router: router, toast: toast).delete(view)
        }
    }
}
