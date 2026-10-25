import Foundation
import SwiftData

@Model
public final class Subtask {
    public var id: UUID = UUID()
    public var title: String = ""
    public var isDone: Bool = false
    public var sortOrder: Double = 0
    public var task: TaskItem?

    public init(title: String, isDone: Bool = false, sortOrder: Double = 0) {
        self.title = title
        self.isDone = isDone
        self.sortOrder = sortOrder
    }
}
