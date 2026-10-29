import Foundation
import TychoCore

enum ScheduleMessages {
    static func rescheduled(_ title: String, to day: Date, dateText: DateText) -> String {
        "Rescheduled “\(title)” to \(dateText.short(day))"
    }

    static func moved(_ title: String, days: Int) -> String {
        let count = abs(days)
        return "Moved “\(title)” \(count) day\(count == 1 ? "" : "s") \(days > 0 ? "later" : "earlier")"
    }
}
