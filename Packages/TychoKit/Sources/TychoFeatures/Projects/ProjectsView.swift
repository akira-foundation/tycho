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
    @State private var filter = ProjectFilter()
    @State private var pendingDelete: Project?
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        content
            .navigationTitle("Projects")
            .navigationSubtitle(ProjectGroup.subtitle(projects))
            .searchable(text: $filter.query, prompt: "Search Projects")
            .searchFocused($isSearchFocused)
            .marksTextEditing(isFocused: isSearchFocused)
            .toolbar { toolbarItems }
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

    @ViewBuilder private var content: some View {
        if projects.isEmpty {
            ContentUnavailableView {
                Label("No Projects", systemImage: "folder")
            } description: {
                Text("Create a project to start organising tasks.")
            } actions: {
                Button("New Project") { router.newProject() }
            }
        } else {
            results(filter.apply(projects))
        }
    }

    @ViewBuilder private func results(_ visible: [Project]) -> some View {
        if visible.isEmpty {
            ContentUnavailableView {
                Label("No Results", systemImage: "magnifyingglass")
            } description: {
                Text("No projects match your search or filters.")
            } actions: {
                Button("Clear Filters") { filter = ProjectFilter() }
            }
        } else {
            summary(of: visible)
        }
    }

    private func summary(of visible: [Project]) -> some View {
        Form {
            ForEach(ProjectGroup.summary(visible, sort: sort)) { group in
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

    @ToolbarContentBuilder private var toolbarItems: some ToolbarContent {
        ToolbarItem {
            Menu("Filter", systemImage: FilterToolbarButton.symbol(filterCount: filter.status == nil ? 0 : 1)) {
                Picker("Status", selection: $filter.status) {
                    Text("All Statuses").tag(ProjectStatus?.none)
                    ForEach(ProjectStatus.allCases) { status in
                        Label(status.title, systemImage: status.symbol).tag(ProjectStatus?.some(status))
                    }
                }
                .pickerStyle(.inline)
            }
            .accessibilityIdentifier("projects.filter")
        }
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

    @ViewBuilder private func menu(for project: Project) -> some View {
        Button(project.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
            toast.perform { try ProjectActions(context: context).toggleFavorite(project) }
        }
        Button("Delete…", role: .destructive) { pendingDelete = project }
    }
}
