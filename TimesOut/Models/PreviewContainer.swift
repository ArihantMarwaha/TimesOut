import SwiftUI
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let schema = Schema([TaskItem.self, Routine.self, RoutineTask.self, SubtaskItem.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        
        if try context.fetch(FetchDescriptor<Routine>()).isEmpty {
            // Sample Routines
            let morningRoutine = Routine(title: "Morning Flow", icon: "sun.max.fill", accentColor: "Orange", priority: .high, isActive: true)
            
            let task1 = RoutineTask(
                title: "Hydrate (8 glasses)", 
                order: 0, 
                parentRoutine: morningRoutine, 
                type: .iterative, 
                targetCount: 8, 
                currentCount: 3
            )
            
            let task2 = RoutineTask(
                title: "Morning Meditation", 
                order: 1, 
                parentRoutine: morningRoutine, 
                type: .oneOff, 
                deadline: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())
            )
            
            let task3 = RoutineTask(
                title: "Deep Work Session", 
                order: 2, 
                parentRoutine: morningRoutine, 
                type: .interval, 
                startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()),
                endTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
            )
            
            let workRoutine = Routine(title: "Evening Wind Down", icon: "moon.stars.fill", accentColor: "Purple", priority: .medium, isActive: false)
            
            context.insert(morningRoutine)
            context.insert(workRoutine)
            
            try? context.save()
        }
        
        // ... (rest of TaskItem seeding remains largely the same but ensuring no crashes)
        
        return container
    } catch {
        print("Preview error: \(error)")
        fatalError("Failed to create preview container: \(error)")
    }
}()
