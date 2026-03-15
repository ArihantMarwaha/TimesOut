import SwiftUI

struct DraftRoutineTask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var priority: TaskPriority
    var subtaskTitles: [String]
    var order: Int
    
    init(id: UUID = UUID(), title: String, priority: TaskPriority = .medium, subtaskTitles: [String] = [], order: Int = 0) {
        self.id = id
        self.title = title
        self.priority = priority
        self.subtaskTitles = subtaskTitles
        self.order = order
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
    
    @State private var newTaskTitle = ""
    @State private var editingTaskID: UUID?
    
    private let routineIcons = [
        "sun.max.fill", "moon.stars.fill", "cup.and.saucer.fill",
        "brain.head.profile", "heart.fill", "book.fill", 
        "briefcase.fill", "figure.run", "checklist",
        "tray.fill", "bed.double.fill", "clock.fill", "calendar",
        "bolt.fill", "star.fill", "flag.fill", "pills.fill",
        "laptopcomputer", "cart.fill", "house.fill"
    ]
    
    init(routine: Routine? = nil, onSave: @escaping (String, String, String, [DraftRoutineTask]) -> Void) {
        self.routine = routine
        self.onSave = onSave
        self._title = State(initialValue: routine?.title ?? "")
        self._icon = State(initialValue: routine?.icon ?? "sparkles")
        self._accentColor = State(initialValue: routine?.accentColor ?? AppAccentColor.yellow.rawValue)
        
        let existingTasks = (routine?.tasks ?? []).sorted(by: { $0.order < $1.order }).map { 
            DraftRoutineTask(id: $0.id, title: $0.title, priority: $0.priority, subtaskTitles: $0.subtaskTitles, order: $0.order) 
        }
        self._tasks = State(initialValue: existingTasks)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                accentColorSection
                tasksSection
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
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                        .fontWeight(.semibold)
                }
            }
            .withAppTheme()
        }
        .presentationDetents([.large])
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            TextField("Routine Title", text: $title)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
            
            HStack {
                Text("Icon")
                    .fontDesign(.monospaced)
                    .fontWeight(.semibold)
                Spacer()
                
                iconPickerMenu
            }
        } header: {
            Text("Routine Details")
                .fontWeight(.semibold)
                .fontWidth(.expanded)
        }
    }
    
    @ViewBuilder
    private var iconPickerMenu: some View {
        Menu {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 10) {
                    ForEach(routineIcons, id: \.self) { (iconName: String) in
                        Button {
                            self.icon = iconName
                        } label: {
                            Image(systemName: iconName)
                                .font(.title2)
                                .foregroundColor(self.icon == iconName ? .primary : .secondary)
                        }
                    }
                }
                .padding()
            }
        } label: {
            Image(systemName: icon)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(currentAccentColor.opacity(0.1))
                .foregroundColor(currentAccentColor)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    @ViewBuilder
    private var accentColorSection: some View {
        Section {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(AppAccentColor.allCases) { accent in
                        let isSelected = accentColor == accent.rawValue
                        Button {
                            accentColor = accent.rawValue
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(accent.color)
                                    .frame(width: 32, height: 32)
                                
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
    }
    
    @ViewBuilder
    private var tasksSection: some View {
        Section("Tasks") {
            ForEach($tasks) { $task in
                taskRow(for: $task)
            }
            .onDelete { indexSet in
                tasks.remove(atOffsets: indexSet)
            }
            .onMove { from, to in
                tasks.move(fromOffsets: from, toOffset: to)
            }
            
            newTaskRow
        }
        .fontWeight(.semibold)
        .fontWidth(.expanded)
    }
    
    @ViewBuilder
    private func taskRow(for task: Binding<DraftRoutineTask>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                priorityPicker(for: task)
                
                TextField("Task Title", text: task.title)
                    .fontDesign(.monospaced)
                
                Spacer()
                
                editSubtasksButton(for: task.wrappedValue)
            }
            
            if editingTaskID == task.wrappedValue.id {
                SubtaskEditView(subtaskTitles: task.subtaskTitles, accentColor: currentAccentColor)
                    .padding(.leading, 30)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else if !task.wrappedValue.subtaskTitles.isEmpty {
                Text("\(task.wrappedValue.subtaskTitles.count) subtasks")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .fontWidth(.expanded)
                    .foregroundColor(.secondary)
                    .padding(.leading, 30)
            }
        }
        .padding(.vertical, 4)
    }
    
    @ViewBuilder
    private func priorityPicker(for task: Binding<DraftRoutineTask>) -> some View {
        Menu {
            ForEach(TaskPriority.allCases, id: \.self) { (p: TaskPriority) in
                Button {
                    task.wrappedValue.priority = p
                } label: {
                    Label(p.title, systemImage: p.icon)
                }
            }
        } label: {
            Image(systemName: task.wrappedValue.priority.icon)
                .foregroundColor(task.wrappedValue.priority.color)
                .font(.title3)
        }
    }
    
    @ViewBuilder
    private func editSubtasksButton(for task: DraftRoutineTask) -> some View {
        Button {
            withAnimation {
                if editingTaskID == task.id {
                    editingTaskID = nil
                } else {
                    editingTaskID = task.id
                }
            }
        } label: {
            Image(systemName: "list.bullet.indent")
                .foregroundColor(editingTaskID == task.id ? currentAccentColor : .secondary)
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var newTaskRow: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .foregroundColor(currentAccentColor)
            
            TextField("New Task Title", text: $newTaskTitle)
                .fontDesign(.monospaced)
                .onSubmit {
                    addTask()
                }
            
            if !newTaskTitle.isEmpty {
                Button(action: addTask) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(currentAccentColor)
                        .font(.title3)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private var currentAccentColor: Color {
        AppAccentColor(rawValue: accentColor)?.color ?? selectedAccent.color
    }
    
    private func addTask() {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            withAnimation {
                tasks.append(DraftRoutineTask(title: trimmed, order: tasks.count))
                newTaskTitle = ""
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
    
    private func saveRoutine() {
        // Ensure order is correct before saving
        for i in 0..<tasks.count {
            tasks[i].order = i
        }
        onSave(title, icon, accentColor, tasks)
        dismiss()
    }
}

struct SubtaskEditView: View {
    @Binding var subtaskTitles: [String]
    let accentColor: Color
    @State private var newSubtask = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(subtaskTitles.indices, id: \.self) { index in
                HStack {
                    Image(systemName: "circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Subtask", text: $subtaskTitles[index])
                        .font(.system(size: 14))
                        .fontDesign(.monospaced)
                    
                    Button {
                        subtaskTitles.remove(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack {
                Image(systemName: "plus")
                    .font(.caption)
                    .foregroundColor(accentColor)
                
                TextField("Add subtask...", text: $newSubtask)
                    .font(.system(size: 14))
                    .fontDesign(.monospaced)
                    .onSubmit {
                        addSubtask()
                    }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .glassEffect(.clear, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private func addSubtask() {
        let trimmed = newSubtask.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            subtaskTitles.append(trimmed)
            newSubtask = ""
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}

#Preview {
    RoutineFormView { _, _, _, _ in }
        .withAppTheme()
}
