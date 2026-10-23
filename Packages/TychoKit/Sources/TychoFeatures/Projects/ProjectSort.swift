import Foundation
import TychoCore

enum ProjectSort: String, CaseIterable, Identifiable {
    case recent, name, due, progress

    var id: String { rawValue }
    var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    func sorted(_ projects: [Project]) -> [Project] {
        switch self {
        case .recent:
            projects.sorted { $0.updatedAt > $1.updatedAt }
        case .name:
            projects.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        case .due:
            projects.sorted { lhs, rhs in
                switch (lhs.due, rhs.due) {
                case (let left?, let right?): left < right
                case (_?, nil): true
                case (nil, _?): false
                case (nil, nil): lhs.sortOrder < rhs.sortOrder
                }
            }
        case .progress:
            projects.sorted { $0.progress > $1.progress }
        }
    }
}

enum ProjectLayout: String, CaseIterable, Identifiable {
    case grid, list

    var id: String { rawValue }
    var symbol: String { self == .grid ? "square.grid.2x2" : "list.bullet" }
}
