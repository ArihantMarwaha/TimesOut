import Foundation

extension Calendar {
    // A simple range representing the start and end of a day.
    struct DayRange {
        let start: Date
        let end: Date
    }
    
    // Returns the start and end of the day for the given date.
    func dayRange(for date: Date) -> DayRange {
        let start = startOfDay(for: date)
        let end = self.date(byAdding: .day, value: 1, to: start)!
        return DayRange(start: start, end: end)
    }
    
    // A 24-hour threshold from now, used for determining which completed tasks to show in the daily view.
    var archiveThreshold: Date {
        date(byAdding: .hour, value: -24, to: Date())!
    }
}
