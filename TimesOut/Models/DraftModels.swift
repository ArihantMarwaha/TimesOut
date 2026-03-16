import Foundation

/// A lightweight, Identifiable version of SubtaskItem for use in forms before saving to SwiftData.
struct DraftSubtask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

/// A lightweight, Identifiable version of RoutineTask for use in forms before saving to SwiftData.
struct DraftRoutineTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var order: Int
    
    // New Configuration Fields
    var type: RoutineTaskType = .oneOff
    var deadline: Date?
    var startTime: Date?
    var endTime: Date?
    var targetCount: Int = 1
    
    init(
        id: UUID = UUID(),
        title: String,
        order: Int = 0,
        type: RoutineTaskType = .oneOff,
        deadline: Date? = nil,
        startTime: Date? = nil,
        endTime: Date? = nil,
        targetCount: Int = 1
    ) {
        self.id = id
        self.title = title
        self.order = order
        self.type = type
        self.deadline = deadline
        self.startTime = startTime
        self.endTime = endTime
        self.targetCount = targetCount
    }
}
