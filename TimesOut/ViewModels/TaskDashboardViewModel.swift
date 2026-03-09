import SwiftUI
import SwiftData

@Observable
final class TaskDashboardViewModel {
    
    // MARK: - UI State
    var selectedDate: Date = Date()
    
    // MARK: - Filtering Logic
    
    /// Filters tasks for the "Daily" section based on the selected date.
    /// Rules:
    /// 1. NO due date OR due date is exactly on the selectedDate (ignores time).
    /// 2. Must not be archived (completed > 24 hours ago).
    func dailyTasks(from allTasks: [TaskItem]) -> [TaskItem] {
        return allTasks.filter { task in
            guard isTaskActive(task) else { return false }
            
            if let dueDate = task.dueDate {
                return Calendar.current.isDate(dueDate, inSameDayAs: selectedDate)
            } else {
                return true // No due date always shows in Daily
            }
        }
    }
    
    /// Filters tasks for the "Long Term" section.
    /// Rules:
    /// 1. Must have a due date.
    /// 2. Must not be archived (completed > 24 hours ago).
    /// Note: If a task with a due date falls on selectedDate, it will appear in both Daily and Long Term.
    func longTermTasks(from allTasks: [TaskItem]) -> [TaskItem] {
        return allTasks.filter { task in
            guard isTaskActive(task) else { return false }
            return task.dueDate != nil
        }
    }
    
    /// Calculates the completion percentage for the selected date.
    func dailyProgress(from allTasks: [TaskItem]) -> Double {
        let daily = dailyTasks(from: allTasks)
        guard !daily.isEmpty else { return 0 }
        
        let completed = daily.filter { $0.isCompleted }.count
        return Double(completed) / Double(daily.count)
    }
    
    // MARK: - Helpers
    
    /// Helper to determine if a task should be visible in active views (not archived).
    /// - Returns: True if incomplete, OR completed within the last 24 hours.
    private func isTaskActive(_ task: TaskItem) -> Bool {
        if !task.isCompleted {
            return true
        }
        
        // If completed, check how long ago
        if let completedAt = task.completedAt {
            let hoursSinceCompletion = Date().timeIntervalSince(completedAt) / 3600
            return hoursSinceCompletion <= 24
        }
        
        // Fallback if completedAt is nil for some reason
        return false
    }
}
