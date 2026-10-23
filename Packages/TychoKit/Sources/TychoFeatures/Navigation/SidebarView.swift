import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct SidebarView: View {
    @Environment(Router.self) private var router
    @Environment(ToastCenter.self) private var toast
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Project> { !$0.isArchived }, sort: \Project.sortOrder) private var projects: [Project]

    var body: some View {
        @Bindable var router = router
        List(selection: $router.sidebarItem) {
            Section {
                Label("Home", systemImage: "house").tag(SidebarItem.home)
                Label("My Tasks", systemImage: "checklist").tag(SidebarItem.myTasks)
                Label("Projects", systemImage: "folder").tag(SidebarItem.projects)
            }
            let favorites = projects.filter(\.isFavorite)
            if !favorites.isEmpty {
                Section("Favorites") {
                    ForEach(favorites) { row($0) }
                }
            }
            Section("Projects") {
                ForEach(projects) { row($0) }
                    .onMove(perform: move)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("Tycho")
        .toolbar {
            ToolbarItem {
                Button("New Project", systemImage: "plus") { router.newProject() }
            }
            #if os(iOS)
            ToolbarItem(placement: .bottomBar) {
                Button("Settings", systemImage: "gearshape") { router.showSettings() }
            }
            #endif
        }
    }

    private func row(_ project: Project) -> some View {
        Label {
            Text(project.name).lineLimit(1)
        } icon: {
            ProjectGlyph(symbol: project.symbol, color: project.color.tint, size: 18)
        }
        .tag(SidebarItem.project(project.id))
    }

    private func move(from source: IndexSet, to destination: Int) {
        guard let index = source.first else { return }
        let moved = projects[index]
        let siblings = projects.filter { $0 !== moved }
        let target = destination > index ? destination - 1 : destination
        toast.perform { try ProjectActions(context: context).move(moved, to: target, among: siblings) }
    }
}
