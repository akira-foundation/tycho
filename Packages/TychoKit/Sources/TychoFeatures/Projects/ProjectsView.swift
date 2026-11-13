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
    @State private var pendingDelete: Project?

    var body: some View {
        Group {
            if projects.isEmpty {
                ContentUnavailableView {
                    Label("No Projects", systemImage: "folder")
                } description: {
                    Text("Create a project to start organising tasks.")
                } actions: {
                    Button("New Project") { router.newProject() }
                }
            } else {
                Form {
                    ForEach(ProjectGroup.summary(projects, sort: sort)) { group in
                        ForEach(Array(group.projects.enumerated()), id: \.element.id) { offset, project in
                            Section {
                                Button {
                                    router.openProject(project.id, tab: .board)
                                } label: {
                                    ProjectSummaryRow(project: project)
                                }
                                .buttonStyle(.plain)
                                .contextMenu { menu(for: project) }
                                .accessibilityIdentifier("project.row.\(project.key)")
                            } header: {
                                if offset == 0 { Text(group.title) }
                            }
                        }
                    }
                }
                .formStyle(.grouped)
            }
        }
        .navigationTitle("Projects")
        .navigationSubtitle(ProjectGroup.subtitle(projects))
        .toolbar {
            ToolbarItem {
                Menu("Sort By", systemImage: "arrow.up.arrow.down") {
                    Picker("Sort By", selection: $sort) {
                        ForEach(ProjectSort.allCases) { Text($0.title).tag($0) }
                    }
                    .pickerStyle(.inline)
                }
                .accessibilityIdentifier("projects.sort")
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
