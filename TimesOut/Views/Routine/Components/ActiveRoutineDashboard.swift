import SwiftUI
import SwiftData

struct RoutineTaskRow: View {
    @Bindable var task: RoutineTask
    let accentColor: Color
    
    var body: some View {
        switch task.type {
        case .iterative:
            RoutineTaskIterativeRow(task: task, accentColor: accentColor)
        case .interval:
            RoutineTaskIntervalRow(task: task, accentColor: accentColor)
        case .oneOff:
            RoutineTaskOneOffRow(task: task, accentColor: accentColor)
        }
    }
}

struct ActiveRoutineDashboard: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Routine> { $0.isActive == true }) private var activeRoutines: [Routine]
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    var body: some View {
        if let routine = activeRoutines.first {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(routine.title)
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .fontWidth(.expanded)
                        
                        Text("Active Lifestyle")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(currentAccentColor(for: routine).opacity(0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: routine.icon)
                            .foregroundColor(currentAccentColor(for: routine))
                            .font(.title3)
                    }
                }
                
                // Overall Progress
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Overall Progress")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(overallProgress(for: routine) * 100))%")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(currentAccentColor(for: routine))
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(currentAccentColor(for: routine).opacity(0.1))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(currentAccentColor(for: routine))
                                .frame(width: geo.size.width * CGFloat(overallProgress(for: routine)))
                        }
                    }
                    .frame(height: 8)
                }
                
                // Task List
                VStack(spacing: 0) {
                    if let tasks = routine.tasks?.sorted(by: { $0.order < $1.order }) {
                        ForEach(tasks) { task in
                            RoutineTaskRow(task: task, accentColor: currentAccentColor(for: routine))
                            
                            if task.id != tasks.last?.id {
                                Divider()
                                    .padding(.leading, 56)
                                    .opacity(0.5)
                            }
                        }
                    }
                }
            }
            .padding(24)
            .background {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            .onAppear {
                RoutineManager.shared.refreshHabits(modelContext: modelContext)
            }
        }
    }
    
    private func currentAccentColor(for routine: Routine) -> Color {
        AppAccentColor(rawValue: routine.accentColor)?.color ?? selectedAccent.color
    }
    
    private func overallProgress(for routine: Routine) -> Double {
        guard let tasks = routine.tasks, !tasks.isEmpty else { return 0 }
        
        let completedCount = tasks.filter { task in
            if task.type == .iterative {
                return task.currentCount >= task.targetCount
            } else {
                return task.isCompleted
            }
        }.count
        
        return Double(completedCount) / Double(tasks.count)
    }
}

#Preview {
    ZStack {
        Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
        VStack {
            ActiveRoutineDashboard()
            Spacer()
        }
        .padding(.top)
    }
    .modelContainer(previewContainer)
}
