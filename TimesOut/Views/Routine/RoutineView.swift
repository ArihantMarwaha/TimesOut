import SwiftUI
import SwiftData

struct RoutineView: View {
    var viewModel: TaskDashboardViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Routine.createdAt, order: .reverse) private var routines: [Routine]
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]
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
                        
                        // Section: My Routines
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Your Routines")
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
                                            let isApplied = viewModel.isRoutineApplied(routine, allTasks: allTasks)
                                            RoutineCard(routine: routine, isApplied: isApplied) {
                                                withAnimation {
                                                    viewModel.toggleRoutine(routine, context: modelContext, allTasks: allTasks)
                                                }
                                                // Feedback for the user
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            }
                                            .onLongPressGesture {
                                                routineToEdit = routine
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
            .sheet(isPresented: $isShowingForm) {
                RoutineFormView { newTitle, newIcon, newAccent, draftTasks in
                    let routine = Routine(title: newTitle, icon: newIcon, accentColor: newAccent)
                    routine.tasks = draftTasks.map { 
                        RoutineTask(title: $0.title, priority: $0.priority, subtaskTitles: $0.subtaskTitles) 
                    }
                    modelContext.insert(routine)
                    try? modelContext.save()
                }
            }
            .sheet(item: $routineToEdit) { routine in
                RoutineFormView(routine: routine) { newTitle, newIcon, newAccent, draftTasks in
                    routine.title = newTitle
                    routine.icon = newIcon
                    routine.accentColor = newAccent
                    
                    // Reconcile Tasks
                    let existingTasks = routine.tasks ?? []
                    let draftIDs = Set(draftTasks.map { $0.id })
                    
                    // Remove deleted
                    for existing in existingTasks {
                        if !draftIDs.contains(existing.id) {
                            modelContext.delete(existing)
                        }
                    }
                    
                    // Update or Add
                    var updatedTasks: [RoutineTask] = []
                    for draft in draftTasks {
                        if let existing = existingTasks.first(where: { $0.id == draft.id }) {
                            existing.title = draft.title
                            existing.priority = draft.priority
                            existing.subtaskTitles = draft.subtaskTitles
                            updatedTasks.append(existing)
                        } else {
                            let newTask = RoutineTask(title: draft.title, priority: draft.priority, subtaskTitles: draft.subtaskTitles)
                            newTask.parentRoutine = routine
                            updatedTasks.append(newTask)
                        }
                    }
                    routine.tasks = updatedTasks
                    
                    try? modelContext.save()
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
        let morning = Routine(title: "Morning Routine", icon: "sun.max.fill", accentColor: "orange")
        let morningTasks = [
            RoutineTask(title: "Morning Meditation", priority: .medium, parentRoutine: morning),
            RoutineTask(title: "Hydrate (500ml)", priority: .high, parentRoutine: morning),
            RoutineTask(title: "Morning Coffee", priority: .low, parentRoutine: morning),
            RoutineTask(title: "Planned Workout", priority: .medium, parentRoutine: morning, subtaskTitles: ["15 min Yoga", "10 min HIIT", "Cool down stretch"]),
            RoutineTask(title: "Pack Work Bag", priority: .high, parentRoutine: morning, subtaskTitles: ["Laptop", "Charger", "LunchBox"])
        ]
        morning.tasks = morningTasks
        
        let focus = Routine(title: "Work Focused", icon: "brain.head.profile", accentColor: "purple")
        let focusTasks = [
            RoutineTask(title: "Review Emails", priority: .low, parentRoutine: focus),
            RoutineTask(title: "Time Block Schedule", priority: .medium, parentRoutine: focus),
            RoutineTask(title: "Deep Work Sprint", priority: .high, parentRoutine: focus, subtaskTitles: ["No distractions", "Focus on top goal", "Take 5m break after"])
        ]
        focus.tasks = focusTasks
        
        modelContext.insert(morning)
        modelContext.insert(focus)
        
        try? modelContext.save()
    }
}

#Preview {
    RoutineView(viewModel: TaskDashboardViewModel())
        .withAppTheme()
        .modelContainer(previewContainer)
}
