import Foundation
import SwiftData

@Model
public final class Team {
    public var id: UUID = UUID()
    public var slug: String = ""
    public var name: String = ""
    public var symbol: String = "person.3"
    public var colorHex: UInt32 = 0x6B7280
    public var summary: String = ""
    public var workspace: Workspace?
    @Relationship(deleteRule: .nullify, inverse: \Member.team) public var members: [Member]? = []
    @Relationship(deleteRule: .nullify, inverse: \Project.team) public var projects: [Project]? = []

    public init(slug: String, name: String, symbol: String, colorHex: UInt32, summary: String) {
        self.slug = slug
        self.name = name
        self.symbol = symbol
        self.colorHex = colorHex
        self.summary = summary
    }
}
