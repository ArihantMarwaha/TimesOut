import Foundation
import SwiftData

@Model
final class RoutineTask: Identifiable {
    var id: UUID
    var title: String
    var priority: TaskPriority
    var order: Int
    var createdAt: Date
    
    // Relationship back to the parent Routine
    var parentRoutine: Routine?
    
    // Simple titles for subtasks in the template
    var subtaskTitles: [String]
    
    init(id: UUID = UUID(), title: String, priority: TaskPriority = .medium, order: Int = 0, createdAt: Date = Date(), parentRoutine: Routine? = nil, subtaskTitles: [String] = []) {
        self.id = id
        self.title = title
        self.priority = priority
        self.order = order
        self.createdAt = createdAt
        self.parentRoutine = parentRoutine
        self.subtaskTitles = subtaskTitles
    }
}
