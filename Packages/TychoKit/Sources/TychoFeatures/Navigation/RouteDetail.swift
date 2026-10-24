import SwiftUI
import TychoDesign

struct RouteDetail: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .home:
            HomeView()
        case .myTasks:
            MyTasksView()
        case .tasks:
            TasksView()
        case .calendar, .timeline:
            EmptyState(title: "Coming soon", symbol: "hammer", message: "This view is on its way.")
        case .projects:
            ProjectsView()
        case .project(let id, let tab):
            ProjectDetailView(projectID: id, tab: tab)
        }
    }
}
