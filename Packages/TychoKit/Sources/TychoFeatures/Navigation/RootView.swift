import SwiftData
import SwiftUI
import TychoCore
import TychoDesign

struct RootView: View {
    @Environment(Router.self) private var router
    @Query(sort: \Workspace.createdAt) private var workspaces: [Workspace]

    var body: some View {
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
            .sheet(isPresented: $router.isCreatingProject) { NewProjectSheet(project: nil) }
        }
    }
}
