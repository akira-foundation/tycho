import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct ProjectDetailView: View {
    @Environment(Router.self) private var router
    @Query private var matches: [Project]
    @State private var editing = false
    @State private var isSavingView = false
    @State private var renamingView: SavedView?
    @Environment(\.isCompactWidth) private var isCompact
    private let tab: ProjectTab

    init(projectID: UUID, tab: ProjectTab) {
        _matches = Query(filter: #Predicate<Project> { $0.id == projectID })
        self.tab = tab
    }

    var body: some View {
        if let project = matches.first {
            let target = ProjectTabTarget(tab: tab, in: project)
            ProjectTabContent(project: project, target: target)
                .id(target.stateKey)
                .navigationTitle(target.title)
                .navigationSubtitle(Self.subtitle(project))
                .toolbar {
                    ToolbarItem { ProjectTabPicker(selection: builtInSelection(project)) }
                    if isCompact { ToolbarSpacer(.fixed) }
                    ToolbarItem {
                        ProjectMenu(
                            project: project, tab: tab, onSave: { isSavingView = true },
                            onRename: { renamingView = $0 }, onEdit: { editing = true })
                    }
                    ToolbarItem { Button("New Task", systemImage: "plus") { router.newTask() } }
                }
                .sheet(isPresented: $editing) { NewProjectSheet(project: project) }
                .sheet(isPresented: $isSavingView) { SaveViewSheet(project: project) }
                .sheet(item: $renamingView) { RenameViewSheet(view: $0) }
                .blocksNavigation(while: editing || isSavingView || renamingView != nil)
        } else {
            EmptyState(title: "Project Not Found", symbol: "questionmark.folder", message: "It may have been deleted.")
        }
    }

    private func builtInSelection(_ project: Project) -> Binding<ProjectBuiltInTab?> {
        Binding(
            get: { ProjectTabTarget.pickerSelection(for: tab) },
            set: { selection in
                guard let selection else { return }
                router.openProject(project.id, tab: .builtIn(selection))
            })
    }

    static func subtitle(_ project: Project) -> String {
        "\(project.status.title) · \(project.progress)%"
    }
}
