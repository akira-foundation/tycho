import SwiftUI
import TychoCore
import TychoDesign

struct CalendarLegend: View {
    let tasks: [TaskItem]

    static func projects(in tasks: [TaskItem]) -> [Project] {
        var seen = Set<UUID>()
        return tasks.compactMap(\.project).filter { seen.insert($0.id).inserted }.sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        let projects = Self.projects(in: tasks)
        if projects.count > 1 {
            HStack(spacing: 10) {
                ForEach(projects.prefix(5)) { project in
                    HStack(spacing: Spacing.s1) {
                        Circle().fill(project.color.tint).frame(width: 6, height: 6)
                        Text(project.name).lineLimit(1)
                    }
                }
            }
            .tychoFont(.xs)
            .foregroundStyle(Token.text2.color)
        }
    }
}
