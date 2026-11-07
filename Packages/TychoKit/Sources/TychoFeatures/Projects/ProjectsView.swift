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
                ContentUnavailableView {
                    Label("No Projects", systemImage: "folder")
                } description: {
                    Text("Create a project to start organising tasks.")
                } actions: {
                    Button("New Project") { router.newProject() }
                }
            case (false, .grid):
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 260), spacing: 16)], spacing: 16) {
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
                    .padding()
                }
            case (false, .list):
                List(sorted) { project in
                    Button {
                        router.openProject(project.id, tab: .board)
                    } label: {
                        HStack(spacing: 12) {
                            ProjectGlyph(symbol: project.symbol, color: project.color.tint)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(project.name)
                                Text(project.status.title).font(.caption).foregroundStyle(project.status.tint)
                            }
                            Spacer()
                            ProgressRing(percent: project.progress, color: project.color.tint)
                            Text("\(project.progress)%")
                                .font(.callout)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .contextMenu { menu(for: project) }
                }
            }
        }
        .navigationTitle("Projects")
        .toolbar {
            ToolbarItem {
                Menu("View Options", systemImage: "ellipsis.circle") {
                    Picker("View As", selection: $layout) {
                        ForEach(ProjectLayout.allCases) { Label($0.title, systemImage: $0.symbol).tag($0) }
                    }
                    .pickerStyle(.inline)
                    Picker("Sort By", selection: $sort) {
                        ForEach(ProjectSort.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.menu)
                }
                .accessibilityIdentifier("projects.options")
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
