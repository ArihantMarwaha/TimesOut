import SwiftUI
import SwiftData

@MainActor
@Observable
final class TaskDashboardViewModel {
    
    // MARK: - UI State
    var selectedDate: Date = Date()
    
    // MARK: - Predicates
    
    /// Predicate for "Daily" tasks:
    /// 1. NOT archived (not completed > 24 hours ago).
    /// 2. (No due date) OR (due date on selectedDate).
    func dailyTasksPredicate() -> Predicate<TaskItem> {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let archiveThreshold = Date().addingTimeInterval(-24 * 3600)
        
        return #Predicate<TaskItem> { task in
            (task.isCompleted == false || (task.completedAt != nil && task.completedAt! > archiveThreshold)) &&
            (task.dueDate == nil || (task.dueDate != nil && task.dueDate! >= startOfDay && task.dueDate! < endOfDay))
        }
    }
    
    /// Predicate for "Long Term" tasks:
    /// 1. NOT archived.
    /// 2. Has a due date.
    /// 3. Due date is NOT on the selectedDate.
    func longTermTasksPredicate() -> Predicate<TaskItem> {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let archiveThreshold = Date().addingTimeInterval(-24 * 3600)
        
        return #Predicate<TaskItem> { task in
            (task.isCompleted == false || (task.completedAt != nil && task.completedAt! > archiveThreshold)) &&
            (task.dueDate != nil && (task.dueDate! < startOfDay || task.dueDate! >= endOfDay))
        }
    }

    // MARK: - Filtering Logic (Helper methods for non-Query contexts)
    
    func dailyTasks(from allTasks: [TaskItem]) -> [TaskItem] {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let archiveThreshold = Date().addingTimeInterval(-24 * 3600)

        return allTasks.filter { task in
            let isActive = !task.isCompleted || (task.completedAt != nil && task.completedAt! > archiveThreshold)
            guard isActive else { return false }
            
            if let dueDate = task.dueDate {
                return dueDate >= startOfDay && dueDate < endOfDay
            } else {
                return true 
            }
        }
    }
    
    func longTermTasks(from allTasks: [TaskItem]) -> [TaskItem] {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let archiveThreshold = Date().addingTimeInterval(-24 * 3600)

        return allTasks.filter { task in
            let isActive = !task.isCompleted || (task.completedAt != nil && task.completedAt! > archiveThreshold)
            guard isActive else { return false }
            
            if let dueDate = task.dueDate {
                return dueDate < startOfDay || dueDate >= endOfDay
            } else {
                return false
            }
        }
    }
    
    /// Calculates the completion percentage for the selected date.
    func dailyProgress(from allTasks: [TaskItem]) -> Double {
        let daily = dailyTasks(from: allTasks)
        guard !daily.isEmpty else { return 0 }
        
        let completed = daily.filter { $0.isCompleted }.count
        return Double(completed) / Double(daily.count)
    }
    
    // MARK: - Routine Actions
    
    /// Checks if a routine is already applied for the selectedDate.
    func isRoutineApplied(_ routine: Routine, allTasks: [TaskItem]) -> Bool {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return allTasks.contains { task in
            guard let origin = task.originRoutine, let dueDate = task.dueDate else { return false }
            return origin.id == routine.id && dueDate >= startOfDay && dueDate < endOfDay
        }
    }
    
    /// Toggles routine application: adds tasks if not present, removes them if they are.
    func toggleRoutine(_ routine: Routine, container: ModelContainer) {
        let routineID = routine.id
        let date = selectedDate
        
        Task.detached {
            let actor = TaskModelActor(modelContainer: container)
            try? await actor.toggleRoutine(routineID: routineID, selectedDate: date)
        }
    }
    
    // MARK: - Helpers (Private)
    
    private func isTaskActive(_ task: TaskItem) -> Bool {
        if !task.isCompleted {
            return true
        }
        
        if let completedAt = task.completedAt {
            let hoursSinceCompletion = Date().timeIntervalSince(completedAt) / 3600
            return hoursSinceCompletion <= 24
        }
        
        return false
    }
}
