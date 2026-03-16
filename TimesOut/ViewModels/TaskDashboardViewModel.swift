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
    
    // Cached state to prevent redundant filtering on every view refresh
    private var appliedRoutineIDs: Set<UUID> = []
    private var lastProcessedTasksHash: Int = 0
    private var lastProcessedDate: Date = Date()
    
    // MARK: - Predicates
    
    func dailyTasksPredicate() -> Predicate<TaskItem> {
        let start = dayRange.start
        let end = dayRange.end
        let threshold = Calendar.current.archiveThreshold
        
        return #Predicate<TaskItem> { task in
            (task.isCompleted == false || (task.completedAt != nil && task.completedAt! > threshold)) &&
            (task.dueDate == nil || (task.dueDate != nil && task.dueDate! >= start && task.dueDate! < end))
        }
    }
    
    func longTermTasksPredicate() -> Predicate<TaskItem> {
        let start = dayRange.start
        let end = dayRange.end
        let threshold = Calendar.current.archiveThreshold
        
        return #Predicate<TaskItem> { task in
            (task.isCompleted == false || (task.completedAt != nil && task.completedAt! > threshold)) &&
            (task.dueDate != nil && (task.dueDate! < start || task.dueDate! >= end))
        }
    }

    // MARK: - Filtering Logic
    
    func dailyTasks(from allTasks: [TaskItem]) -> [TaskItem] {
        let start = dayRange.start
        let end = dayRange.end
        let threshold = Calendar.current.archiveThreshold

        return allTasks.filter { task in
            let isActive = !task.isCompleted || (task.completedAt != nil && task.completedAt! > threshold)
            if !isActive { return false }
            
            guard let dueDate = task.dueDate else { return true }
            return dueDate >= start && dueDate < end
        }
    }
    
    func longTermTasks(from allTasks: [TaskItem]) -> [TaskItem] {
        let start = dayRange.start
        let end = dayRange.end
        let threshold = Calendar.current.archiveThreshold

        return allTasks.filter { task in
            let isActive = !task.isCompleted || (task.completedAt != nil && task.completedAt! > threshold)
            if !isActive { return false }
            
            guard let dueDate = task.dueDate else { return false }
            return dueDate < start || dueDate >= end
        }
    }

    // MARK: - Optimized Cache Logic
    
    func updateAppliedRoutines(allTasks: [TaskItem]) {
        let range = dayRange
        
        let currentHash = allTasks.count + Int(selectedDate.timeIntervalSince1970)
        guard currentHash != lastProcessedTasksHash || !Calendar.current.isDate(selectedDate, inSameDayAs: lastProcessedDate) else { return }
        
        var appliedSet = Set<UUID>()
        for task in allTasks {
            if let originID = task.originRoutine?.id,
               let dueDate = task.dueDate,
               dueDate >= range.start && dueDate < range.end {
                appliedSet.insert(originID)
            }
        }
        
        self.appliedRoutineIDs = appliedSet
        self.lastProcessedTasksHash = currentHash
        self.lastProcessedDate = selectedDate
    }
    
    func isRoutineApplied(_ routine: Routine) -> Bool {
        appliedRoutineIDs.contains(routine.id)
    }
    
    func dailyProgress(from allTasks: [TaskItem]) -> Double {
        let daily = dailyTasks(from: allTasks)
        guard !daily.isEmpty else { return 0 }
        
        let completed = daily.filter { $0.isCompleted }.count
        return Double(completed) / Double(daily.count)
    }
    
    // MARK: - Routine Actions
    
    func toggleRoutine(_ routine: Routine, container: ModelContainer) {
        let routineID = routine.id
        let date = selectedDate
        
        Task.detached {
            let actor = TaskModelActor(modelContainer: container)
            try? await actor.toggleRoutine(routineID: routineID, selectedDate: date)
        }
    }
}
