import Foundation
import SwiftData

@Model
public final class Milestone {
    public var id: UUID = UUID()
    public var name: String = ""
    public var date: Date?
    public var project: Project?

    public init(name: String, date: Date?) {
        self.name = name
        self.date = date
    }
}
