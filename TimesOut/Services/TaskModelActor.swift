import Foundation
import SwiftData

@ModelActor
public actor TaskModelActor {
    
    /// Toggles routine application: adds tasks if not present, removes them if they are.
    public func toggleRoutine(routineID: UUID, selectedDate: Date) throws {
        // Fetch the routine
        let routinePredicate = #Predicate<Routine> { routine in
            routine.id == routineID
        }
        let routineDescriptor = FetchDescriptor<Routine>(predicate: routinePredicate)
        guard let routine = try modelContext.fetch(routineDescriptor).first else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Fetch all tasks for this routine to filter manually for the date
        // (Due to SwiftData's current Predicate limitations with Optional dates and Calendar calls)
        let tasksPredicate = #Predicate<TaskItem> { task in
            task.originRoutine?.id == routineID
        }
        
        let tasksDescriptor = FetchDescriptor<TaskItem>(predicate: tasksPredicate)
        let allRoutineTasks = try modelContext.fetch(tasksDescriptor)
        
        // Filter locally in the background actor (still better than main thread)
        let appliedTasks = allRoutineTasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate >= startOfDay && dueDate < endOfDay
        }
        
        if !appliedTasks.isEmpty {
            for task in appliedTasks {
                modelContext.delete(task)
            }
        } else {
            let tasks = (routine.tasks ?? []).sorted(by: { $0.order < $1.order })
            let dueDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: selectedDate) ?? selectedDate
            
            for routineTask in tasks {
                let newTask = TaskItem(
                    title: routineTask.title,
                    priority: routineTask.priority,
                    dueDate: dueDate,
                    originRoutine: routine
                )
                
                if !routineTask.subtaskTitles.isEmpty {
                    newTask.subtasks = routineTask.subtaskTitles.map { SubtaskItem(title: $0) }
                }
                
                modelContext.insert(newTask)
            }
        }
        
        try modelContext.save()
    }
}
