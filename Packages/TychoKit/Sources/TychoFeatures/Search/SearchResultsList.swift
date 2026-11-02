import SwiftUI
import TychoCore
import TychoDesign

struct SearchResultsList: View {
    @Environment(Router.self) private var router
    let results: SearchResults
    let scope: SearchScope
    let query: String

    var body: some View {
        let titles = SearchPageModel.sections(results, scope: scope).map(\.title)
        let groups = groups(visibleFor: scope)
        VStack(alignment: .leading, spacing: Spacing.s5) {
            ForEach(Array(zip(titles, groups).enumerated()), id: \.offset) { _, pair in
                let (title, items) = pair
                VStack(alignment: .leading, spacing: Spacing.s2) {
                    Text(title).tychoFont(.xs, weight: .semibold).foregroundStyle(Token.text3.color)
                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            Button {
                                open(item.action)
                            } label: {
                                PaletteRow(item: item, query: query, isHighlighted: false)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .background(Token.surface.color, in: RoundedRectangle(cornerRadius: Radius.md, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: Radius.md, style: .continuous)
                            .strokeBorder(Token.border.color, lineWidth: 1))
                }
            }
        }
    }

    private func groups(visibleFor scope: SearchScope) -> [[PaletteItem]] {
        let all: [(SearchScope, [PaletteItem])] = [
            (.tasks, results.tasks.map(PaletteEntityItems.task)),
            (.projects, results.projects.map(PaletteEntityItems.project)),
            (.files, results.files.map(PaletteEntityItems.file)),
        ]
        return all.filter { ($0.0 == scope || scope == .all) && !$0.1.isEmpty }.map(\.1)
    }

    private func open(_ action: PaletteAction) {
        switch action {
        case .openTask(let id): router.inspect(id)
        case .openProject(let id): router.openProject(id, tab: .board)
        case .openFile(let id): openFile(id)
        default: break
        }
    }

    private func openFile(_ id: UUID) {
        guard let projectID = results.files.first(where: { $0.id == id })?.project?.id else { return }
        router.openProject(projectID, tab: .files)
    }
}
