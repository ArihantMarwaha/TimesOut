import SwiftUI

struct RoutineFormView: View {
    let routine: Routine?
    let onSave: (String, String, String, TaskPriority, Bool, [DraftRoutineTask]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    @State private var title: String
    @State private var icon: String
    @State private var accentColor: String
    @State private var priority: TaskPriority
    @State private var isActive: Bool
    @State private var tasks: [DraftRoutineTask]
    
    @State private var taskToConfigure: DraftRoutineTask?
    
    private let routineIcons = [
        "sun.max.fill", "moon.stars.fill", "cup.and.saucer.fill",
        "brain.head.profile", "heart.fill", "book.fill", 
        "briefcase.fill", "figure.run", "checklist",
        "tray.fill", "bed.double.fill", "clock.fill", "calendar",
        "bolt.fill", "star.fill", "flag.fill", "pills.fill",
        "laptopcomputer", "cart.fill", "house.fill"
    ]
    
    init(routine: Routine? = nil, onSave: @escaping (String, String, String, TaskPriority, Bool, [DraftRoutineTask]) -> Void) {
        self.routine = routine
        self.onSave = onSave
        self._title = State(initialValue: routine?.title ?? "")
        self._icon = State(initialValue: routine?.icon ?? "sparkles")
        self._accentColor = State(initialValue: routine?.accentColor ?? AppAccentColor.yellow.rawValue)
        self._priority = State(initialValue: routine?.priority ?? .medium)
        self._isActive = State(initialValue: routine?.isActive ?? false)
        
        let existingTasks = (routine?.tasks ?? []).sorted(by: { $0.order < $1.order }).map { 
            DraftRoutineTask(
                id: $0.id,
                title: $0.title,
                order: $0.order,
                type: $0.type,
                deadline: $0.deadline,
                startTime: $0.startTime,
                endTime: $0.endTime,
                targetCount: $0.targetCount
            ) 
        }
        self._tasks = State(initialValue: existingTasks)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                RoutineDetailsSection(title: $title)
                
                Section("Settings") {
                    Toggle("Active Template", isOn: $isActive)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .fontWeight(.semibold)
                .fontWidth(.expanded)
                
                RoutineIconPicker(icon: $icon, accentColor: currentAccentColor, icons: routineIcons)
                RoutineAccentColorPicker(accentColor: $accentColor)
                
                Section("Routine Tasks") {
                    SubtaskListView<DraftRoutineTask>.forRoutineTasks(tasks: $tasks, accentColor: currentAccentColor) { taskBinding in
                        taskToConfigure = taskBinding.wrappedValue
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .fontWeight(.semibold)
                .fontWidth(.expanded)
            }
            .navigationTitle(routine == nil ? "New Routine" : "Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRoutine()
                    }
                    .fontWeight(.bold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .withAppTheme()
            .sheet(item: $taskToConfigure) { task in
                if let index = tasks.firstIndex(where: { $0.id == task.id }) {
                    RoutineTaskDetailSheet(task: $tasks[index], accentColor: currentAccentColor)
                }
            }
        }
        .presentationDetents([.large])
    }
    
    private var currentAccentColor: Color {
        AppAccentColor(rawValue: accentColor)?.color ?? selectedAccent.color
    }
    
    private func saveRoutine() {
        for i in 0..<tasks.count {
            tasks[i].order = i
        }
        onSave(title, icon, accentColor, priority, isActive, tasks)
        dismiss()
    }
}

#Preview {
    RoutineFormView { _, _, _, _, _, _ in }
        .withAppTheme()
}
