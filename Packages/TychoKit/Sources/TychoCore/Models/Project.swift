import Foundation
import SwiftData

@Model
public final class Project {
    public var id: UUID = UUID()
    public var key: String = ""
    public var name: String = ""
    public var symbol: String = "folder"
    public var colorRaw: String = ProjectColor.indigo.rawValue
    public var statusRaw: String = ProjectStatus.planning.rawValue
    public var start: Date?
    public var due: Date?
    public var summary: String = ""
    public var isFavorite: Bool = false
    public var isArchived: Bool = false
    public var sortOrder: Double = 0
    public var nextTaskNumber: Int = 1
    public var createdAt: Date = Date.now
    public var updatedAt: Date = Date.now
    public var workspace: Workspace?
    public var lead: Member?
    public var team: Team?
    @Relationship(deleteRule: .nullify, inverse: \Member.projects) public var members: [Member]? = []
    @Relationship(deleteRule: .cascade, inverse: \TaskItem.project) public var tasks: [TaskItem]? = []

    public init(key: String, name: String) {
        self.key = key
        self.name = name
    }

    public var status: ProjectStatus {
        get { ProjectStatus(rawValue: statusRaw) ?? .planning }
        set { statusRaw = newValue.rawValue }
    }

    public var color: ProjectColor {
        get { ProjectColor(rawValue: colorRaw) ?? .indigo }
        set { colorRaw = newValue.rawValue }
    }
}
