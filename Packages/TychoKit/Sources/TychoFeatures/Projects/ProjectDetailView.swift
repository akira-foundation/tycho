import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct ProjectDetailView: View {
    @Environment(Router.self) private var router
    @Query private var matches: [Project]
    @State private var editing = false
    private let tab: ProjectTab

    init(projectID: UUID, tab: ProjectTab) {
        _matches = Query(filter: #Predicate<Project> { $0.id == projectID })
        self.tab = tab
    }

    var body: some View {
        if let project = matches.first {
            VStack(spacing: 0) {
                header(project)
                Divider()
                ProjectTabContent(project: project, tab: tab)
            }
            .background(Token.bg.color)
            .navigationTitle(project.name)
            .toolbar {
                ToolbarItem {
                    Picker("View", selection: Binding(get: { tab }, set: { router.openProject(project.id, tab: $0) })) {
                        ForEach(ProjectTab.allCases, id: \.self) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("project.tab")
                }
                ToolbarItem { Button("Edit Project", systemImage: "slider.horizontal.3") { editing = true } }
                ToolbarItem { Button("New Task", systemImage: "plus") { router.newTask() } }
            }
            .sheet(isPresented: $editing) { NewProjectSheet(project: project) }
        } else {
            EmptyState(title: "Project not found", symbol: "questionmark.folder", message: "It may have been deleted.")
        }
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

struct ProjectTabContent: View {
    let project: Project
    let tab: ProjectTab

    var body: some View {
        switch tab {
        case .list:
            TaskListView(tasks: project.tasks ?? [], project: project)
        case .board:
            BoardView(project: project)
        }
    }
}
