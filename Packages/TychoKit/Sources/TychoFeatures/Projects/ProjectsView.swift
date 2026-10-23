import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct ProjectsView: View {
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Project> { !$0.isArchived }) private var projects: [Project]
    @AppStorage("projects.sort") private var sort = ProjectSort.recent
    @AppStorage("projects.layout") private var layout = ProjectLayout.grid
    @State private var pendingDelete: Project?

    var body: some View {
        let sorted = sort.sorted(projects)
        Group {
            switch (projects.isEmpty, layout) {
            case (true, _):
                EmptyState(
                    title: "No projects yet", symbol: "folder", message: "Create a project to start organising tasks.")
            case (false, .grid):
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: Spacing.s4)], spacing: Spacing.s4) {
                        ForEach(sorted) { project in
                            Button {
                                router.openProject(project.id, tab: .board)
                            } label: {
                                ProjectCard(project: project)
                            }
                            .buttonStyle(.plain)
                            .contextMenu { menu(for: project) }
                        }
                    }
                    .padding(Spacing.s6)
                }
            case (false, .list):
                List(sorted) { project in
                    Button {
                        router.openProject(project.id, tab: .board)
                    } label: {
                        HStack(spacing: Spacing.s3) {
                            ProjectGlyph(symbol: project.symbol, color: project.color.tint)
                            Text(project.name).tychoFont(.base, weight: .medium)
                            StatusPill(status: project.status)
                            Spacer()
                            ProgressRing(percent: project.progress, color: project.color.tint)
                            Text("\(project.progress)%").tychoFont(.xs).monospacedDigit()
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu { menu(for: project) }
                }
            }
        }
        .background(Token.bg.color)
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem {
                Picker("Sort", selection: $sort) {
                    ForEach(ProjectSort.allCases) { Text($0.title).tag($0) }
                }
            }
            ToolbarItem {
                Picker("Layout", selection: $layout) {
                    ForEach(ProjectLayout.allCases) { Image(systemName: $0.symbol).tag($0) }
                }
                .pickerStyle(.segmented)
            }
            ToolbarItem { Button("New Project", systemImage: "plus") { router.newProject() } }
        }
        .confirmationDialog(
            "Delete project?",
            isPresented: Binding(get: { pendingDelete != nil }, set: { if !$0 { pendingDelete = nil } }),
            presenting: pendingDelete
        ) { project in
            Button("Delete \(project.name) and its tasks", role: .destructive) {
                toast.perform { try ProjectActions(context: context).delete(project) }
                pendingDelete = nil
            }
        }
    }

    @ViewBuilder private func menu(for project: Project) -> some View {
        Button(project.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
            toast.perform { try ProjectActions(context: context).toggleFavorite(project) }
        }
        Button("Delete…", role: .destructive) { pendingDelete = project }
    }
}
