import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct RootView: View {
    @Environment(Router.self) private var router
    @Query(sort: \Workspace.createdAt) private var workspaces: [Workspace]

    var body: some View {
        content
            .onChange(of: workspaces.first?.id) {
                router.isCreatingTask = false
                router.isCreatingProject = false
                router.closeInspector()
                router.open(.home)
            }
    }

    @ViewBuilder private var content: some View {
        @Bindable var router = router
        if workspaces.isEmpty {
            OnboardingView()
        } else {
            NavigationSplitView(columnVisibility: $router.columnVisibility) {
                SidebarView()
            } detail: {
                NavigationStack {
                    RouteDetail(route: router.route)
                }
            }
            .background(Token.bg.color)
            .inspector(
                isPresented: Binding(
                    get: { router.inspectedTaskID != nil },
                    set: { if !$0 { router.closeInspector() } }
                )
            ) {
                if let id = router.inspectedTaskID {
                    TaskInspectorView(taskID: id)
                        .id(id)
                        .inspectorColumnWidth(min: 320, ideal: 380, max: 520)
                }
            }
            .sheet(isPresented: $router.isCreatingProject) { NewProjectSheet(project: nil) }
            .sheet(isPresented: $router.isCreatingTask) { NewTaskSheet(status: router.draftStatus) }
            .sheet(isPresented: $router.isShowingSettings) {
                NavigationStack { SettingsView() }
            }
        }
    }
}
