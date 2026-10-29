import SwiftData
import SwiftUI
import TychoCore

struct LiveProjectsTracking: ViewModifier {
    @Query private var projects: [Project]
    let model: TaskViewModel

    func body(content: Content) -> some View {
        content.onChange(of: Set(projects.map(\.id)), initial: true) { _, ids in
            model.liveProjectIDs = ids.isEmpty ? nil : ids
        }
    }
}

extension View {
    func tracksLiveProjects(_ model: TaskViewModel) -> some View {
        modifier(LiveProjectsTracking(model: model))
    }
}
