import Foundation
import SwiftData

@Model
final class Routine: Identifiable {
    var id: UUID
    var title: String
    var icon: String
    var accentColor: String
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade, inverse: \RoutineTask.parentRoutine)
    var tasks: [RoutineTask]?
    
    @Relationship(deleteRule: .nullify, inverse: \TaskItem.originRoutine)
    var instantiatedTasks: [TaskItem]?
    
    init(id: UUID = UUID(), title: String, icon: String = "list.bullet", accentColor: String = "yellow", createdAt: Date = Date(), tasks: [RoutineTask]? = nil, instantiatedTasks: [TaskItem]? = nil) {
        self.id = id
        self.title = title
        self.icon = icon
        self.accentColor = accentColor
        self.createdAt = createdAt
        self.tasks = tasks
        self.instantiatedTasks = instantiatedTasks
    }
}
