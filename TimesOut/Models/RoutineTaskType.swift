import Foundation

enum RoutineTaskType: String, Codable, CaseIterable {
    case oneOff     // Must be done by a deadline
    case interval   // Must be done between two times
    case iterative  // Must be done X number of times
    
    var icon: String {
        switch self {
        case .oneOff: return "timer"
        case .interval: return "clock.badge.checkmark"
        case .iterative: return "arrow.counterclockwise.circle"
        }
    }
    
    var description: String {
        switch self {
        case .oneOff: return "Deadline"
        case .interval: return "Time Window"
        case .iterative: return "Repetitions"
        }
    }
}
