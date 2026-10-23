import SwiftUI
import TychoDesign

struct RouteDetail: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .home:
            EmptyState(title: "Home", symbol: "house", message: "Coming in the next task.")
        case .myTasks:
            EmptyState(title: "My Tasks", symbol: "checklist", message: "Coming in the next task.")
        case .projects:
            EmptyState(title: "Projects", symbol: "folder", message: "Coming in the next task.")
        case .project:
            EmptyState(title: "Project", symbol: "folder", message: "Coming in the next task.")
        }
    }
}
