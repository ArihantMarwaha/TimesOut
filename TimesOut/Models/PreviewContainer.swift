import SwiftUI
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(for: TaskItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        if try context.fetch(FetchDescriptor<TaskItem>()).isEmpty {
            let sample1 = TaskItem(title: "Build Pomodoro Timer", priority: .high, dueDate: Date().addingTimeInterval(3600 * 24))
            let sample2 = TaskItem(title: "Review Design Tweaks", priority: .medium)
            let sample3 = TaskItem(title: "Read up on SwiftData", priority: .low)
            sample3.isCompleted = true
            sample3.completedAt = Date()
            
            let sample4 = TaskItem(title: "Setup Archive View", priority: .high)
            sample4.isCompleted = true
            // Completed 2 days ago
            sample4.completedAt = Date().addingTimeInterval(-86400 * 2)
            
            // Tasks with subtasks
            let sample5 = TaskItem(title: "Launch MVP", priority: .high, dueDate: Date().addingTimeInterval(3600 * 48))
            let sub1 = SubtaskItem(title: "Finalize UI polish")
            let sub2 = SubtaskItem(title: "Write unit tests")
            let sub3 = SubtaskItem(title: "Submit to TestFlight", isCompleted: true)
            sample5.subtasks = [sub1, sub2, sub3]
            
            let sample6 = TaskItem(title: "Morning Routine", priority: .medium)
            let sub4 = SubtaskItem(title: "Meditate 10 mins", isCompleted: true)
            let sub5 = SubtaskItem(title: "Workout 30 mins")
            let sub6 = SubtaskItem(title: "Read 20 pages")
            sample6.subtasks = [sub4, sub5, sub6]
            
            context.insert(sample1)
            context.insert(sample2)
            context.insert(sample3)
            context.insert(sample4)
            context.insert(sample5)
            context.insert(sample6)
            
            try? context.save()
        }
        return container
    } catch {
        fatalError("Failed to create preview container")
    }
}()
