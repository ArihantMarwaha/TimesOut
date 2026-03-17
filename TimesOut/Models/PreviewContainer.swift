import SwiftUI
import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let schema = Schema([TaskItem.self, Routine.self, SubtaskItem.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        
        if try context.fetch(FetchDescriptor<Routine>()).isEmpty {
            // Sample Routines (New Flat Architecture)
            
            let task1 = Routine(
                title: "Hydrate (8 glasses)",
                icon: "drop.fill",
                accentColor: "Blue",
                type: .iterative,
                targetCount: 8,
                currentCount: 3
            )
            
            let task2 = Routine(
                title: "Morning Meditation",
                icon: "sun.max.fill",
                accentColor: "Orange",
                type: .oneOff,
                deadline: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())
            )
            
            let task3 = Routine(
                title: "Deep Work Session",
                icon: "laptopcomputer",
                accentColor: "Purple",
                type: .interval,
                startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()),
                endTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
            )
            
            context.insert(task1)
            context.insert(task2)
            context.insert(task3)
            
            try? context.save()
        }
        
        return container
    } catch {
        print("Preview error: \(error)")
        fatalError("Failed to create preview container: \(error)")
    }
}()
