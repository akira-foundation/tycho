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
            VStack(spacing: 0) {
                header(project)
                Divider()
                ProjectTabContent(project: project, target: target)
                    .id(target.stateKey)
            }
            .background(Token.bg.color)
            .navigationTitle(target.title)
            .toolbar {
                ToolbarItem { ProjectTabPicker(selection: builtInSelection(project), isCompact: isCompact) }
                if isCompact { ToolbarSpacer(.fixed) }
                ToolbarItem {
                    SavedViewTabs(
                        project: project, tab: tab, onSave: { isSavingView = true }, onRename: { renamingView = $0 })
                }
                ToolbarItem { Button("Edit Project", systemImage: "slider.horizontal.3") { editing = true } }
                ToolbarItem { Button("New Task", systemImage: "plus") { router.newTask() } }
            }
            .sheet(isPresented: $editing) { NewProjectSheet(project: project) }
            .sheet(isPresented: $isSavingView) { SaveViewSheet(project: project) }
            .sheet(item: $renamingView) { RenameViewSheet(view: $0) }
            .blocksNavigation(while: editing || isSavingView || renamingView != nil)
        } else {
            EmptyState(title: "Project not found", symbol: "questionmark.folder", message: "It may have been deleted.")
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

    private func header(_ project: Project) -> some View {
        HStack(spacing: Spacing.s3) {
            ProjectGlyph(symbol: project.symbol, color: project.color.tint, size: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(project.name).tychoFont(.xl, weight: .semibold)
                if !project.summary.isEmpty {
                    Text(project.summary).tychoFont(.sm).foregroundStyle(Token.text3.color).lineLimit(1)
                }
            }
            Spacer()
            StatusPill(status: project.status)
            ProgressRing(percent: project.progress, color: project.color.tint, size: 18)
            Text("\(project.progress)%").tychoFont(.xs).monospacedDigit().foregroundStyle(Token.text3.color)
            if let lead = project.lead {
                Avatar(initials: lead.initials, color: lead.tint)
            }
        }
        .padding(.horizontal, Spacing.s6)
        .padding(.vertical, Spacing.s4)
    }
}
