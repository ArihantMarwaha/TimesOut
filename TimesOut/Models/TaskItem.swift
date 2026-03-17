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
    
    var isArchived: Bool
    
    var originRoutine: Routine?
    
    @Relationship(deleteRule: .cascade, inverse: \SubtaskItem.parentTask)
    var subtasks: [SubtaskItem]?
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, isArchived: Bool = false, priority: TaskPriority = .medium, dueDate: Date? = nil, originRoutine: Routine? = nil, createdAt: Date = Date(), completedAt: Date? = nil, subtasks: [SubtaskItem]? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.isArchived = isArchived
        self.priority = priority
        self.dueDate = dueDate
        self.originRoutine = originRoutine
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.subtasks = subtasks
    }
    
    /// Reconciles subtasks and updates task properties.
    func update(
        title: String,
        priority: TaskPriority,
        dueDate: Date?,
        draftSubtasks: [DraftSubtask],
        context: ModelContext
    ) {
        self.title = title
        self.priority = priority
        self.dueDate = dueDate
        
        // Reconcile subtasks
        let existingSubtasks = self.subtasks ?? []
        let draftIDs = Set(draftSubtasks.map { $0.id })
        
        // 1. Remove deleted subtasks
        for subtask in existingSubtasks {
            if !draftIDs.contains(subtask.id) {
                context.delete(subtask)
            }
        }
        
        // 2. Update existing or Add new
        var updatedSubtasks: [SubtaskItem] = []
        for draft in draftSubtasks {
            if let existing = existingSubtasks.first(where: { $0.id == draft.id }) {
                existing.title = draft.title
                existing.isCompleted = draft.isCompleted
                updatedSubtasks.append(existing)
            } else {
                let newSubtask = SubtaskItem(id: draft.id, title: draft.title, isCompleted: draft.isCompleted)
                newSubtask.parentTask = self
                updatedSubtasks.append(newSubtask)
            }
        }
        self.subtasks = updatedSubtasks
        
        // 3. Update completion state based on subtasks if necessary
        updateCompletionState()
    }
    
    /// Toggles the completion state and ensures completedAt is synchronized.
    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
        
        // If un-completing, ensure it's not archived
        if !isCompleted {
            isArchived = false
        }
        
        // If completing a task, also complete all its subtasks
        if isCompleted {
            subtasks?.forEach { $0.isCompleted = true }
        }
    }
    
    /// Updates the completion state based on whether all subtasks are completed.
    func updateCompletionState() {
        guard let subtasks = subtasks, !subtasks.isEmpty else { return }
        
        let allCompleted = subtasks.allSatisfy { $0.isCompleted }
        if allCompleted && !isCompleted {
            isCompleted = true
            completedAt = Date()
        } else if !allCompleted && isCompleted {
            isCompleted = false
            completedAt = nil
        }
    }
}
