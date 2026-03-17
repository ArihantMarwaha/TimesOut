import SwiftUI
import SwiftData

@MainActor
@Observable
final class TaskDashboardViewModel {
    
    // MARK: - UI State
    var selectedDate: Date = Date()
    
    private var dayRange: Calendar.DayRange {
        Calendar.current.dayRange(for: selectedDate)
    }
    
    // MARK: - Predicates
    
    func dailyTasksPredicate() -> Predicate<TaskItem> {
        let start = dayRange.start
        let end = dayRange.end
        
        return #Predicate<TaskItem> { task in
            task.isArchived == false &&
            (task.dueDate == nil || (task.dueDate != nil && task.dueDate! >= start && task.dueDate! < end))
        }
    }
    
    func longTermTasksPredicate() -> Predicate<TaskItem> {
        let start = dayRange.start
        let end = dayRange.end
        
        return #Predicate<TaskItem> { task in
            task.isArchived == false &&
            (task.dueDate != nil && (task.dueDate! < start || task.dueDate! >= end))
        }
    }

    // MARK: - Filtering Logic
    
    func dailyTasks(from allTasks: [TaskItem]) -> [TaskItem] {
        let start = dayRange.start
        let end = dayRange.end

        return allTasks.filter { task in
            if task.isArchived { return false }
            
            guard let dueDate = task.dueDate else { return true }
            return dueDate >= start && dueDate < end
        }
    }
    
    func longTermTasks(from allTasks: [TaskItem]) -> [TaskItem] {
        let start = dayRange.start
        let end = dayRange.end

        return allTasks.filter { task in
            if task.isArchived { return false }
            
            guard let dueDate = task.dueDate else { return false }
            return dueDate < start || dueDate >= end
        }
    }

    func dailyProgress(from allTasks: [TaskItem]) -> Double {
        let daily = dailyTasks(from: allTasks)
        guard !daily.isEmpty else { return 0 }
        
        let completed = daily.filter { $0.isCompleted }.count
        return Double(completed) / Double(daily.count)
    }
    
    /// Finds completed tasks older than 24 hours and marks them as archived.
    func archiveExpiredTasks(in context: ModelContext) {
        let threshold = Calendar.current.archiveThreshold
        
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate<TaskItem> { task in
                task.isCompleted && task.isArchived == false && (task.completedAt != nil && task.completedAt! < threshold)
            }
        )
        
        do {
            let expiredTasks = try context.fetch(descriptor)
            if !expiredTasks.isEmpty {
                for task in expiredTasks {
                    task.isArchived = true
                }
                try context.save()
            }
        } catch {
            print("Failed to archive tasks: \(error)")
        }
    }
}
