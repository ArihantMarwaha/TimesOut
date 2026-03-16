import SwiftUI
import SwiftData

@MainActor
@Observable
final class RoutineManager {
    static let shared = RoutineManager()
    
    // Using simple properties and manually handling defaults for @Observable
    // Alternatively, we can use @AppStorage for persistence and still use @Observable
    var dayStartHour: Int {
        get { UserDefaults.standard.integer(forKey: "day_start_hour") == 0 ? 4 : UserDefaults.standard.integer(forKey: "day_start_hour") }
        set { UserDefaults.standard.set(newValue, forKey: "day_start_hour") }
    }
    
    var wakeUpTime: Double {
        get { 
            let val = UserDefaults.standard.double(forKey: "wake_up_time")
            return val == 0 ? 7.5 * 3600 : val
        }
        set { UserDefaults.standard.set(newValue, forKey: "wake_up_time") }
    }
    
    private init() {}
    
    /// Checks all active routines and resets their tasks if a new logical day has started.
    func refreshHabits(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Routine>(
            predicate: #Predicate<Routine> { $0.isActive == true }
        )
        
        guard let activeRoutines = try? modelContext.fetch(fetchDescriptor) else { return }
        
        let now = Date()
        let calendar = Calendar.current
        
        // Logical Date: Subtract the dayStartHour to determine if we are still in "yesterday"
        guard let adjustedDate = calendar.date(byAdding: .hour, value: -dayStartHour, to: now) else { return }
        
        var hasChanges = false
        
        for routine in activeRoutines {
            guard let tasks = routine.tasks else { continue }
            
            for task in tasks {
                // If the last reset was NOT on the same day as our current adjusted date, reset it.
                if !calendar.isDate(task.lastResetDate, inSameDayAs: adjustedDate) {
                    task.currentCount = 0
                    task.isCompleted = false
                    task.lastResetDate = now 
                    hasChanges = true
                }
            }
        }
        
        if hasChanges {
            try? modelContext.save()
        }
    }
    
    /// Activates a routine and deactivates others if desired (maintaining the "Active Mode" concept).
    func activateRoutine(_ routine: Routine, modelContext: ModelContext, exclusive: Bool = true) {
        if exclusive {
            let fetchDescriptor = FetchDescriptor<Routine>()
            if let allRoutines = try? modelContext.fetch(fetchDescriptor) {
                for r in allRoutines {
                    r.isActive = false
                }
            }
        }
        
        routine.isActive = true
        refreshHabits(modelContext: modelContext) 
        try? modelContext.save()
    }
}
