import Foundation
import SwiftData
import TychoCore

@MainActor
struct TaskMoveHandler {
    let context: ModelContext

    func drop(_ ids: [UUID], into status: TaskStatus, before target: TaskItem?, in tasks: [TaskItem]) throws -> Bool {
        guard let id = ids.first, let moved = tasks.first(where: { $0.id == id }), moved !== target else {
            return false
        }
        let siblings =
            tasks
            .filter { $0.status == status && $0 !== moved }
            .sorted { $0.sortOrder < $1.sortOrder }
        let index = target.flatMap { target in siblings.firstIndex { $0 === target } } ?? siblings.count
        try TaskActions(context: context).move(moved, to: status, at: index, among: siblings)
        return true
    }
}
