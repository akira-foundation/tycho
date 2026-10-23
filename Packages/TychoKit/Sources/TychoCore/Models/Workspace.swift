import Foundation
import SwiftData

@Model
public final class Workspace {
    public var id: UUID = UUID()
    public var name: String = ""
    public var createdAt: Date = Date.now
    @Relationship(deleteRule: .cascade, inverse: \Project.workspace) public var projects: [Project]? = []
    @Relationship(deleteRule: .cascade, inverse: \Member.workspace) public var members: [Member]? = []
    @Relationship(deleteRule: .cascade, inverse: \Team.workspace) public var teams: [Team]? = []

    public init(name: String) {
        self.name = name
    }

    public var me: Member? { (members ?? []).first { $0.isMe } }
}
