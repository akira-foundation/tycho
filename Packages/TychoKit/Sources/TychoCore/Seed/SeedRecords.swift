import Foundation

struct SeedTeam {
    let slug: String
    let name: String
    let symbol: String
    let color: UInt32
    let summary: String
}

struct SeedMember {
    let ref: String
    let name: String
    let email: String
    let role: MemberRole
    let team: String
    let title: String
    let color: UInt32
}

struct SeedProject {
    let ref: String
    let key: String
    let name: String
    let symbol: String
    let color: ProjectColor
    let status: ProjectStatus
    let team: String
    let lead: String
    let due: Int
    let start: Int
    let favorite: Bool
    let members: [String]
    let summary: String
    let lastMinutes: Int
}

struct SeedTask {
    let project: String
    let title: String
    let status: TaskStatus
    let assignee: String
    let priority: TaskPriority
    let due: Int?
    var labels: [TaskLabel] = []
    var estimate: String?
    var length = 4
    var ageDays = 12
    var favorite = false
    var notes = ""
    var subtasks: [(String, Bool)] = []
    var blockedBy: [Int] = []
}

struct SeedMilestone {
    let project: String
    let name: String
    let day: Int
}

struct SeedEvent {
    let title: String
    let day: Int
    let time: String
    let project: String
}

struct SeedFile {
    let project: String
    let name: String
    let bytes: Int
    let by: String
    let minutesAgo: Int
    var task: Int?
}
