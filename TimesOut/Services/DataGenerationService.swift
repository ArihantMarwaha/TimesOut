import Foundation
import SwiftData
import SwiftUI

@MainActor
final class DataGenerationService {
    
    static func seedAllData(in context: ModelContext) {
        // 1. Clear existing data first to avoid duplicates
        clearAllData(in: context)
        
        // --- 2. Create Routines ---
        
        // One-Off Routine (Deadline)
        let routineOneOff = Routine(
            title: "Morning Meditation",
            icon: "brain.head.profile",
            accentColor: "Cyan",
            type: .oneOff,
            deadline: Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())
        )
        
        // Iterative Routine (Repetitions)
        let routineIterative = Routine(
            title: "Drink Water",
            icon: "cup.and.saucer.fill",
            accentColor: "Blue",
            type: .iterative,
            targetCount: 8,
            currentCount: 3
        )
        
        // Interval Routine (Time Window)
        let routineInterval = Routine(
            title: "Deep Work Block",
            icon: "laptopcomputer",
            accentColor: "Purple",
            type: .interval,
            startTime: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()),
            endTime: Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())
        )
        
        context.insert(routineOneOff)
        context.insert(routineIterative)
        context.insert(routineInterval)
        
        // --- 3. Create TaskItems ---
        
        // High Priority Overdue Task
        let overdueTask = TaskItem(
            title: "Submit Project Proposal",
            priority: .high,
            dueDate: Calendar.current.date(byAdding: .day, value: -1, to: Date())
        )
        
        // Medium Priority Task with Subtasks (Partially Completed)
        let subtasks = [
            SubtaskItem(title: "Research competitors", isCompleted: true),
            SubtaskItem(title: "Draft outline", isCompleted: false),
            SubtaskItem(title: "Review with team", isCompleted: false)
        ]
        let taskWithSubtasks = TaskItem(
            title: "Q1 Strategy Plan",
            priority: .medium,
            dueDate: Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            subtasks: subtasks
        )
        // Link subtasks to parent
        subtasks.forEach { $0.parentTask = taskWithSubtasks }
        
        // Low Priority No Deadline Task
        let lowPriorityTask = TaskItem(
            title: "Read 'Clean Code' book",
            priority: .low
        )
        
        // Recently Completed Task (Visible in Daily View)
        let completedTask = TaskItem(
            title: "Morning Workout",
            isCompleted: true,
            priority: .medium,
            completedAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date())
        )
        
        // Archived Task (Completed yesterday)
        let archivedTask = TaskItem(
            title: "Grocery Shopping",
            isCompleted: true,
            isArchived: true,
            priority: .medium,
            completedAt: Calendar.current.date(byAdding: .day, value: -2, to: Date())
        )
        
        context.insert(overdueTask)
        context.insert(taskWithSubtasks)
        context.insert(lowPriorityTask)
        context.insert(completedTask)
        context.insert(archivedTask)
        
        // Save
        try? context.save()
    }
    
    static func clearAllData(in context: ModelContext) {
        do {
            try context.delete(model: TaskItem.self)
            try context.delete(model: Routine.self)
            try context.delete(model: SubtaskItem.self)
            try context.save()
        } catch {
            print("Failed to clear data: \(error)")
        }
    }
}
