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
                                                viewModel.toggleRoutine(routine, container: modelContext.container)
                                                // Feedback for the user
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
            .sheet(isPresented: $isShowingForm) {
                RoutineFormView { newTitle, newIcon, newAccent, draftTasks in
                    let routine = Routine(title: newTitle, icon: newIcon, accentColor: newAccent)
                    routine.tasks = draftTasks.map { 
                        RoutineTask(title: $0.title, priority: $0.priority, order: $0.order, subtaskTitles: $0.subtaskTitles) 
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
                            existing.order = draft.order
                            existing.subtaskTitles = draft.subtaskTitles
                            updatedTasks.append(existing)
                        } else {
                            let newTask = RoutineTask(title: draft.title, priority: draft.priority, order: draft.order, subtaskTitles: draft.subtaskTitles)
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
        let morning = Routine(title: "Morning Routine", icon: "sun.max.fill", accentColor: "Orange")
        let morningTasks = [
            RoutineTask(title: "Morning Meditation", priority: .medium, order: 0, parentRoutine: morning),
            RoutineTask(title: "Hydrate (500ml)", priority: .high, order: 1, parentRoutine: morning),
            RoutineTask(title: "Morning Coffee", priority: .low, order: 2, parentRoutine: morning),
            RoutineTask(title: "Planned Workout", priority: .medium, order: 3, parentRoutine: morning, subtaskTitles: ["15 min Yoga", "10 min HIIT", "Cool down stretch"]),
            RoutineTask(title: "Pack Work Bag", priority: .high, order: 4, parentRoutine: morning, subtaskTitles: ["Laptop", "Charger", "LunchBox"])
        ]
        morning.tasks = morningTasks
        
        let focus = Routine(title: "Work Focused", icon: "brain.head.profile", accentColor: "Purple")
        let focusTasks = [
            RoutineTask(title: "Review Emails", priority: .low, order: 0, parentRoutine: focus),
            RoutineTask(title: "Time Block Schedule", priority: .medium, order: 1, parentRoutine: focus),
            RoutineTask(title: "Deep Work Sprint", priority: .high, order: 2, parentRoutine: focus, subtaskTitles: ["No distractions", "Focus on top goal", "Take 5m break after"])
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
