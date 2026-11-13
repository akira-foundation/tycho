import TychoCore

enum MyTasksMode: String, TaskViewMode {
    case list
    case board
    case table
    case calendar

    static let fallback = MyTasksMode.list

    var layout: ProjectBuiltInTab {
        switch self {
        case .list: .list
        case .board: .board
        case .table: .table
        case .calendar: .calendar
        }
    }
}
