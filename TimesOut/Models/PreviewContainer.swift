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
            
            context.insert(sample1)
            context.insert(sample2)
            context.insert(sample3)
            context.insert(sample4)
            
            try? context.save()
        }
        return container
    } catch {
        fatalError("Failed to create preview container")
    }
}()
