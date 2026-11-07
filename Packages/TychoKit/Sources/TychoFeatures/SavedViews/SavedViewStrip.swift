import SwiftUI
import TychoCore
import TychoDesign

struct SavedViewStrip: View {
    @Environment(Router.self) private var router
    let project: Project
    let tab: ProjectTab
    let onSave: () -> Void

    var body: some View {
        let views = SavedView.ordered(in: project)
        if !views.isEmpty {
            ScrollView(.horizontal) {
                HStack(spacing: Spacing.s2) {
                    Picker("Saved Views", selection: selection) {
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
            }
            .scrollIndicators(.never)
            .background(.bar)
            .accessibilityIdentifier("savedViews.strip")
        }
    }

    static func selectedView(for tab: ProjectTab) -> UUID? {
        guard case .savedView(let id) = tab else { return nil }
        return id
    }

    private var selection: Binding<UUID?> {
        Binding(
            get: { Self.selectedView(for: tab) },
            set: { id in
                guard let id else { return }
                router.openProject(project.id, tab: .savedView(id))
            })
    }
}
