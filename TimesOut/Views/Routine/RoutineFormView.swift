import SwiftUI

struct DraftRoutineTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var priority: TaskPriority
    var subtaskTitles: [String]
    
    init(id: UUID = UUID(), title: String, priority: TaskPriority = .medium, subtaskTitles: [String] = []) {
        self.id = id
        self.title = title
        self.priority = priority
        self.subtaskTitles = subtaskTitles
    }
}

struct RoutineFormView: View {
    let routine: Routine?
    let onSave: (String, String, String, [DraftRoutineTask]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    @State private var title: String
    @State private var icon: String
    @State private var accentColor: String
    @State private var tasks: [DraftRoutineTask]
    
    @State private var isAddingTask = false
    @State private var newTaskTitle = ""
    
    private let routineIcons = [
        "brain.head.profile",
        "heart.fill","book.fill", "briefcase.fill",
        "figure.run", "checklist",
        "tray.fill", "bed.double.fill", "clock.fill", "calendar"
    ]
    
    init(routine: Routine? = nil, onSave: @escaping (String, String, String, [DraftRoutineTask]) -> Void) {
        self.routine = routine
        self.onSave = onSave
        self._title = State(initialValue: routine?.title ?? "")
        self._icon = State(initialValue: routine?.icon ?? "sparkles")
        self._accentColor = State(initialValue: routine?.accentColor ?? "yellow")
        
        let existingTasks = routine?.tasks?.map { 
            DraftRoutineTask(id: $0.id, title: $0.title, priority: $0.priority, subtaskTitles: $0.subtaskTitles) 
        } ?? []
        self._tasks = State(initialValue: existingTasks)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Routine Title", text: $title)
                        .font(.system(size: 20, weight: .semibold, design: .monospaced))
                    
                    HStack {
                        Text("Appearance")
                        Spacer()
                        
                        // Icon Picker Menu
                        Menu {
                            ForEach(routineIcons, id: \.self) { iconName in
                                Button {
                                    self.icon = iconName
                                } label: {
                                    Label("", systemImage: iconName)
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: icon)
                                    .font(.title3)
                                Image(systemName: "chevron.up.down")
                                    .font(.caption2)
                            }
                            .foregroundColor(AppAccentColor(rawValue: accentColor.capitalized)?.color ?? selectedAccent.color)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.primary.opacity(0.05))
                            .clipShape(Capsule())
                        }
                    }
                } header: {
                    Text("Routine Details")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                }
                
                Section {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(AppAccentColor.allCases) { accent in
                                let isSelected = accentColor.lowercased() == accent.rawValue.lowercased()
                                Button {
                                    accentColor = accent.rawValue.lowercased()
                                } label: {
                                    ZStack {
                                        Circle()
                                            .fill(accent.color)
                                            .frame(width: 30, height: 30)
                                        
                                        if isSelected {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                    }
                } header: {
                    Text("Accent Color")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                }
                
                Section("Tasks") {
                    ForEach($tasks) { $task in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Image(systemName: task.priority.icon)
                                    .foregroundColor(task.priority.color)
                                
                                TextField("Task Title", text: $task.title)
                                    .fontDesign(.monospaced)
                                
                                Spacer()
                                
                                Button {
                                    tasks.removeAll(where: { $0.id == task.id })
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.8))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Simple display of subtasks count
                            if !task.subtaskTitles.isEmpty {
                                Text("\(task.subtaskTitles.count) subtasks")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 30)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(selectedAccent.color)
                        
                        TextField("New Task Title", text: $newTaskTitle)
                            .fontDesign(.monospaced)
                            .onSubmit {
                                addTask()
                            }
                    }
                }
            }
            .navigationTitle(routine == nil ? "New Routine" : "Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, icon, accentColor, tasks)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .withAppTheme()
        }
        .presentationDetents([.large])
    }
    
    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            tasks.append(DraftRoutineTask(title: trimmed))
            newTaskTitle = ""
        }
    }
}

#Preview {
    RoutineFormView { _, _, _, _ in }
        .withAppTheme()
}
