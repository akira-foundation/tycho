import Foundation
import SwiftData

@Model
public final class Member {
    public var id: UUID = UUID()
    public var name: String = ""
    public var email: String = ""
    public var title: String = ""
    public var colorHex: UInt32 = 0x6B7280
    public var roleRaw: String = MemberRole.member.rawValue
    public var isMe: Bool = false
    public var workspace: Workspace?
    public var team: Team?
    @Relationship(deleteRule: .nullify, inverse: \TaskItem.assignee) public var assignedTasks: [TaskItem]? = []
    @Relationship(deleteRule: .nullify, inverse: \Project.lead) public var ledProjects: [Project]? = []
    public var projects: [Project]? = []

    public init(
        name: String,
        email: String,
        title: String = "",
        colorHex: UInt32 = 0x6B7280,
        role: MemberRole = .member,
        isMe: Bool = false
    ) {
        self.name = name
        self.email = email
        self.title = title
        self.colorHex = colorHex
        self.roleRaw = role.rawValue
        self.isMe = isMe
    }

    public var role: MemberRole {
        get { MemberRole(rawValue: roleRaw) ?? .member }
        set { roleRaw = newValue.rawValue }
    }

    public var initials: String {
        name.split(separator: " ").prefix(2).compactMap(\.first).map(String.init).joined().uppercased()
    }

    public var firstName: String { name.split(separator: " ").first.map(String.init) ?? name }
}
