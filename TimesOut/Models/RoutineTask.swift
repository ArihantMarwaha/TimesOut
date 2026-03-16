import Foundation
import SwiftData

@Model
final class RoutineTask: Identifiable {
    var id: UUID
    var title: String
    var order: Int
    var createdAt: Date
    
    // Relationship back to the parent Routine
    var parentRoutine: Routine?
    
    // New Configuration Properties
    var type: RoutineTaskType = RoutineTaskType.oneOff
    var deadline: Date?
    var startTime: Date?
    var endTime: Date?
    var targetCount: Int = 1
    
    // Live State (Resets Daily)
    var currentCount: Int = 0
    var isCompleted: Bool = false
    var lastResetDate: Date = Date()
    
    init(
        id: UUID = UUID(),
        title: String,
        order: Int = 0,
        createdAt: Date = Date(),
        parentRoutine: Routine? = nil,
        type: RoutineTaskType = .oneOff,
        deadline: Date? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        targetCount: Int = 1,
        currentCount: Int = 0,
        isCompleted: Bool = false,
        lastResetDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.order = order
        self.createdAt = createdAt
        self.parentRoutine = parentRoutine
        self.type = type
        self.deadline = deadline
        self.startTime = startTime
        self.endTime = endTime
        self.targetCount = targetCount
        self.currentCount = currentCount
        self.isCompleted = isCompleted
        self.lastResetDate = lastResetDate
    }
}
