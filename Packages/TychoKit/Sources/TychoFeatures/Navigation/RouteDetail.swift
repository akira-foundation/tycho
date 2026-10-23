import SwiftUI
import TychoDesign

struct RouteDetail: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .home:
            HomeView()
        case .myTasks:
            EmptyState(title: "My Tasks", symbol: "checklist", message: "Coming in the next task.")
        case .projects:
            ProjectsView()
        case .project(let id, let tab):
            ProjectDetailView(projectID: id, tab: tab)
        }
    }
}
