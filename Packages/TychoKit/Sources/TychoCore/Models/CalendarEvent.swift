import Foundation
import SwiftData

@Model
public final class CalendarEvent {
    public var id: UUID = UUID()
    public var title: String = ""
    public var date: Date?
    public var time: String = ""
    public var project: Project?

    public init(title: String, date: Date?, time: String) {
        self.title = title
        self.date = date
        self.time = time
    }
}
