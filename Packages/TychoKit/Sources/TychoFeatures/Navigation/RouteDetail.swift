import SwiftUI

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
        case .calendar:
            WorkspaceCalendarView()
        case .timeline:
            WorkspaceTimelineView()
        case .projects:
            ProjectsView()
        case .project(let id, let tab):
            ProjectDetailView(projectID: id, tab: tab)
        }
    }
}
