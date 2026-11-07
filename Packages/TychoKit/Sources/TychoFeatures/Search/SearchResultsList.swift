import SwiftUI
import TychoCore

struct SearchResultsList: View {
    @Environment(Router.self) private var router
    let results: SearchResults
    let scope: SearchScope
    let query: String

    var body: some View {
        let titles = SearchPageModel.sections(results, scope: scope).map(\.title)
        let groups = groups(visibleFor: scope)
        List {
            ForEach(Array(zip(titles, groups).enumerated()), id: \.offset) { _, pair in
                let (title, items) = pair
                Section(title) {
                    ForEach(items) { item in
                        Button {
                            open(item.action)
                        } label: {
                            SearchResultRow(item: item, query: query)
                        }
                        .buttonStyle(.plain)
                    }
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

struct SearchResultRow: View {
    let item: PaletteItem
    let query: String

    var body: some View {
        HStack(spacing: 12) {
            PaletteVisualIcon(visual: item.visual).frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(PaletteHighlight.title(item.title, query: query)).lineLimit(1)
                if let subtitle = item.subtitle {
                    Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
            }
            Spacer(minLength: 8)
            if let trailing = item.trailing {
                Text(trailing).font(.caption.monospaced()).foregroundStyle(.secondary)
            }
        }
        .contentShape(Rectangle())
    }
}
