import Foundation
import SwiftData

@Model
final class Routine: Identifiable {
    var id: UUID
    var title: String
    var icon: String
    var accentColor: String
    var priority: TaskPriority
    var createdAt: Date
    var isActive: Bool = false
    
    @Relationship(deleteRule: .cascade, inverse: \RoutineTask.parentRoutine)
    var tasks: [RoutineTask]?
    
    init(id: UUID = UUID(), title: String, icon: String = "list.bullet", accentColor: String = "yellow", priority: TaskPriority = .medium, createdAt: Date = Date(), tasks: [RoutineTask]? = nil, isActive: Bool = false) {
        self.id = id
        self.title = title
        self.icon = icon
        self.accentColor = accentColor
        self.priority = priority
        self.createdAt = createdAt
        self.tasks = tasks
        self.isActive = isActive
    }
}
