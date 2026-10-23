import TychoCore

enum HomeTab: String, CaseIterable, Identifiable {
    case upcoming, overdue, completed

    var id: String { rawValue }
    var title: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    func tasks(in summary: HomeSummary) -> [TaskItem] {
        let all =
            switch self {
            case .upcoming: summary.upcoming
            case .overdue: summary.overdueMine
            case .completed: summary.completedMine
            }
        return Array(all.prefix(7))
    }
}

enum Greeting {
    static func text(hour: Int) -> String {
        switch hour {
        case ..<12: "Good morning"
        case ..<18: "Good afternoon"
        default: "Good evening"
        }
    }
}
