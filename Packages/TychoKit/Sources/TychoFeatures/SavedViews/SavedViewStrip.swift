import SwiftUI
import TychoCore
import TychoDesign

struct SavedViewStrip: View {
    @Environment(Router.self) private var router
    let project: Project
    let tab: ProjectTab
    let layout: ProjectBuiltInTab
    let onSave: () -> Void

    var body: some View {
        let views = SavedView.ordered(in: project)
        if !views.isEmpty {
            ScrollView(.horizontal) {
                HStack(spacing: Spacing.s2) {
                    Picker("Saved Views", selection: selection) {
                        Text("All Tasks").tag(UUID?.none)
                        ForEach(views) { Text($0.name).tag(UUID?.some($0.id)) }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .fixedSize()
                    Button("Save View…", systemImage: "plus", action: onSave)
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                        .help("Save the current filters as a view")
                        .accessibilityIdentifier("savedViews.add")
                }
                .padding(.horizontal)
                .padding(.vertical, Spacing.s2)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("savedViews.strip")
            }
            .scrollIndicators(.never)
        }
    }

    static func selectedView(for tab: ProjectTab) -> UUID? {
        guard case .savedView(let id) = tab else { return nil }
        return id
    }

    private var selection: Binding<UUID?> {
        Binding(
            get: { Self.selectedView(for: tab) },
            set: { router.openProject(project.id, tab: Self.tab(opening: $0, layout: layout)) })
    }

    static func tab(opening savedViewID: UUID?, layout: ProjectBuiltInTab) -> ProjectTab {
        savedViewID.map { .savedView($0) } ?? .builtIn(layout)
    }
}
