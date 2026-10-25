import Foundation
import SwiftData

@testable import TychoCore

@MainActor
func makeTestContext() throws -> ModelContext {
    ModelContext(try TychoSchema.makeContainer(inMemory: true))
}

let referenceNow: Date = {
    var components = DateComponents()
    components.year = 2026
    components.month = 10
    components.day = 13
    components.hour = 10
    return utcCalendar.date(from: components)!
}()

let utcCalendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    calendar.firstWeekday = 2
    return calendar
}()

func day(_ offset: Int, hour: Int = 12) -> Date {
    let start = utcCalendar.startOfDay(for: referenceNow)
    let shifted = utcCalendar.date(byAdding: .day, value: offset, to: start)!
    return utcCalendar.date(byAdding: .hour, value: hour, to: shifted)!
}
