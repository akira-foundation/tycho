import Foundation
import TychoCore

enum NewTaskTarget {
    static func project(current: UUID?, projects: [Project]) -> Project? {
        let live = projects.filter { !$0.isArchived }.sorted { $0.sortOrder < $1.sortOrder }
        if let current, let open = live.first(where: { $0.id == current }) {
            return open
        }
        return live.first
    }
}
