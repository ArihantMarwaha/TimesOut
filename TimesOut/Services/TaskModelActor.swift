import Foundation
import SwiftData

@ModelActor
public actor TaskModelActor {
    
    /// Toggles routine application: adds ONE task with many subtasks if not present, removes it if it is.
    public func toggleRoutine(routineID: UUID, selectedDate: Date) throws {
        // Fetch the routine
        let routinePredicate = #Predicate<Routine> { routine in
            routine.id == routineID
        }
        let routineDescriptor = FetchDescriptor<Routine>(predicate: routinePredicate)
        guard let routine = try modelContext.fetch(routineDescriptor).first else { return }
        
        let calendar = Calendar.current
        let range = calendar.dayRange(for: selectedDate)
        
        // Fetch existing task for this routine on the selected day
        let tasksPredicate = #Predicate<TaskItem> { task in
            task.originRoutine?.id == routineID
        }
        
        let tasksDescriptor = FetchDescriptor<TaskItem>(predicate: tasksPredicate)
        let allRoutineTasks = try modelContext.fetch(tasksDescriptor)
        
        // Filter locally for the specific day
        let appliedTasks = allRoutineTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate >= range.start && dueDate < range.end
        }
        
        if !appliedTasks.isEmpty {
            // Delete the parent task (cascades to subtasks)
            for task in appliedTasks {
                modelContext.delete(task)
            }
        } else {
            // Create a single TaskItem for the routine
            let dueDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? selectedDate
            
            let newTask = TaskItem(
                title: routine.title,
                priority: routine.priority,
                dueDate: dueDate,
                originRoutine: routine
            )
            
            // Map routine tasks to SubtaskItems
            if let routineTasks = routine.tasks {
                let sortedTasks = routineTasks.sorted(by: { $0.order < $1.order })
                newTask.subtasks = sortedTasks.map { SubtaskItem(title: $0.title) }
            }
            
            modelContext.insert(newTask)
        }
        
        try modelContext.save()
    }
}
