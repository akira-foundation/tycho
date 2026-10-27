import SwiftData
import TychoCore

extension ToastCenter {
    func isStored(_ task: TaskItem, in context: ModelContext) -> Bool {
        do {
            return try TaskActions(context: context).isStored(task)
        } catch {
            report(error)
            return false
        }
    }
}
