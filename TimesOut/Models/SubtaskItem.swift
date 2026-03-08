import Foundation
import SwiftData

@Model
final class SubtaskItem: Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    // Relationship back to the parent TaskItem
    var parentTask: TaskItem?
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}
