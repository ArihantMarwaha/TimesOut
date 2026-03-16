import SwiftUI
import SwiftData

struct RoutineView: View {
    var viewModel: TaskDashboardViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Routine.createdAt, order: .reverse) private var routines: [Routine]
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    @State private var isShowingForm = false
    @State private var routineToEdit: Routine? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Section: Make New Routine
                        DailyRoutineButton {
                            isShowingForm = true
                        }
                        .padding(.top, 20)
                        
                        // Section: Active Lifestyle Progress
                        ActiveRoutineDashboard()
                        
                        // Section: My Templates
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Routine Templates")
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontWidth(.expanded)
                                .padding(.horizontal)
                            
                            if routines.isEmpty {
                                Text("No routines yet. Tap 'Make Routine' above to get started.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            } else {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 20) {
                                        ForEach(routines) { routine in
                                            RoutineCard(routine: routine, isApplied: routine.isActive) {
                                                withAnimation {
                                                    RoutineManager.shared.activateRoutine(routine, modelContext: modelContext)
                                                }
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            }
                                            .contextMenu {
                                                Button {
                                                    routineToEdit = routine
                                                } label: {
                                                    Label("Edit Routine", systemImage: "pencil")
                                                }
                                                
                                                Button(role: .destructive) {
                                                    modelContext.delete(routine)
                                                    try? modelContext.save()
                                                } label: {
                                                    Label("Delete Routine", systemImage: "trash")
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Routine")
            .toolbarTitleDisplayMode(.inlineLarge)
            .sheet(isPresented: $isShowingForm) {
                RoutineFormView { newTitle, newIcon, newAccent, newPriority, active, draftTasks in
                    let routine = Routine(title: newTitle, icon: newIcon, accentColor: newAccent, priority: newPriority, isActive: active)
                    routine.tasks = draftTasks.map { 
                        RoutineTask(
                            title: $0.title, 
                            order: $0.order, 
                            parentRoutine: routine,
                            type: $0.type,
                            deadline: $0.deadline,
                            startTime: $0.startTime,
                            endTime: $0.endTime,
                            targetCount: $0.targetCount
                        ) 
                    }
                    modelContext.insert(routine)
                    
                    if active {
                        RoutineManager.shared.activateRoutine(routine, modelContext: modelContext)
                    } else {
                        try? modelContext.save()
                    }
                }
            }
            .sheet(item: $routineToEdit) { routine in
                RoutineFormView(routine: routine) { newTitle, newIcon, newAccent, newPriority, active, draftTasks in
                    routine.title = newTitle
                    routine.icon = newIcon
                    routine.accentColor = newAccent
                    routine.priority = newPriority
                    routine.isActive = active
                    
                    let existingTasks = routine.tasks ?? []
                    let draftIDs = Set(draftTasks.map { $0.id })
                    
                    for existing in existingTasks {
                        if !draftIDs.contains(existing.id) {
                            modelContext.delete(existing)
                        }
                    }
                    
                    var updatedTasks: [RoutineTask] = []
                    for draft in draftTasks {
                        if let existing = existingTasks.first(where: { $0.id == draft.id }) {
                            existing.title = draft.title
                            existing.order = draft.order
                            existing.type = draft.type
                            existing.deadline = draft.deadline
                            existing.startTime = draft.startTime
                            existing.endTime = draft.endTime
                            existing.targetCount = draft.targetCount
                            updatedTasks.append(existing)
                        } else {
                            let newTask = RoutineTask(
                                title: draft.title, 
                                order: draft.order, 
                                parentRoutine: routine,
                                type: draft.type,
                                deadline: draft.deadline,
                                startTime: draft.startTime,
                                endTime: draft.endTime,
                                targetCount: draft.targetCount
                            )
                            updatedTasks.append(newTask)
                        }
                    }
                    routine.tasks = updatedTasks
                    
                    if active {
                        RoutineManager.shared.activateRoutine(routine, modelContext: modelContext)
                    } else {
                        try? modelContext.save()
                    }
                }
            }
        }
        .onAppear {
            seedRoutines()
        }
    }
    
    private func seedRoutines() {
        guard routines.isEmpty else { return }
        
        // Seed some basic templates
        let comeback = Routine(title: "Comeback Mode", icon: "sparkles", accentColor: "Orange", priority: .high)
        let comebackTasks = [
            RoutineTask(title: "Morning Meditation", order: 0, parentRoutine: comeback, type: .oneOff, deadline: Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())),
            RoutineTask(title: "Water Intake", order: 1, parentRoutine: comeback, type: .iterative, targetCount: 8),
            RoutineTask(title: "Deep Work", order: 2, parentRoutine: comeback, type: .interval, startTime: Calendar.current.date(bySettingHour: 10, minute: 0, second: 0, of: Date()), endTime: Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date()))
        ]
        comeback.tasks = comebackTasks
        
        modelContext.insert(comeback)
        try? modelContext.save()
    }
}

#Preview {
    RoutineView(viewModel: TaskDashboardViewModel())
        .withAppTheme()
        .modelContainer(previewContainer)
}
