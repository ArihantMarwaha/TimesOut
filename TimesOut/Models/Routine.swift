import Foundation
import SwiftData

@Model
final class Routine: Identifiable {
    var id: UUID
    var title: String
    var icon: String
    var accentColor: String
    var createdAt: Date
    
    // 1. The Polymorphic Type
    var type: RoutineTaskType = RoutineTaskType.oneOff
    
    // 2. Configuration Properties (depending on type)
    var deadline: Date?
    var startTime: Date?
    var endTime: Date?
    var targetCount: Int = 1
    
    // 3. Live Interactive State
    var currentCount: Int = 0
    var isCompleted: Bool = false
    
    // 4. Daily Reset Tracking
    var lastUpdatedDate: Date = Date()
    
    init(
        id: UUID = UUID(),
        title: String,
        icon: String = "list.bullet",
        accentColor: String = "Yellow",
        createdAt: Date = Date(),
        type: RoutineTaskType = .oneOff,
        deadline: Date? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        targetCount: Int = 1,
        currentCount: Int = 0,
        isCompleted: Bool = false,
        lastUpdatedDate: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.accentColor = accentColor
        self.createdAt = createdAt
        self.type = type
        self.deadline = deadline
        self.startTime = startTime
        self.endTime = endTime
        self.targetCount = targetCount
        self.currentCount = currentCount
        self.isCompleted = isCompleted
        self.lastUpdatedDate = lastUpdatedDate
    }
}
