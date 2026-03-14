import Foundation
import SwiftData

@Model
final class TaskItem: Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var priority: TaskPriority
    var dueDate: Date?
    var createdAt: Date
    var completedAt: Date?
    var originRoutineID: UUID?
    
    @Relationship(deleteRule: .cascade, inverse: \SubtaskItem.parentTask)
    var subtasks: [SubtaskItem]?
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, priority: TaskPriority = .medium, dueDate: Date? = nil, originRoutineID: UUID? = nil, createdAt: Date = Date(), completedAt: Date? = nil, subtasks: [SubtaskItem]? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.originRoutineID = originRoutineID
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.subtasks = subtasks
    }
}
