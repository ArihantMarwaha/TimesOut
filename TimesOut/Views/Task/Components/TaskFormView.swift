import SwiftUI

struct DraftSubtask: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

struct TaskFormView: View {
    let task: TaskItem?
    let onSave: (String, TaskPriority, Date?, [DraftSubtask]) -> Void
    
    @State private var editedTitle: String
    @State private var priority: TaskPriority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var draftSubtasks: [DraftSubtask]
    @State private var newSubtaskTitle: String = ""
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    init(task: TaskItem? = nil, onSave: @escaping (String, TaskPriority, Date?, [DraftSubtask]) -> Void) {
        self.task = task
        self.onSave = onSave
        self._editedTitle = State(initialValue: task?.title ?? "")
        self._priority = State(initialValue: task?.priority ?? .medium)
        self._hasDueDate = State(initialValue: task?.dueDate != nil)
        
        let initialDate: Date
        if let taskDate = task?.dueDate {
            initialDate = taskDate
        } else {
            // Default to 11:59 PM of the current day (or the task's existing day if it somehow exists)
            let baseDate = task?.dueDate ?? Date()
            initialDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: baseDate) ?? baseDate
        }
        self._dueDate = State(initialValue: initialDate)
        
        let existingSubtasks = task?.subtasks?.map { DraftSubtask(id: $0.id, title: $0.title, isCompleted: $0.isCompleted) } ?? []
        self._draftSubtasks = State(initialValue: existingSubtasks)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task title", text: $editedTitle)
                        .font(.system(size: 18))
                        .fontDesign(.monospaced)
                } header: {
                    if task != nil {
                        Text("Task Name")
                    } else {
                         Text("Task Details")
                            .fontWeight(.semibold)
                            .fontWidth(.expanded)
                    }
                }
                
                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { p in
                            Image(systemName: p.icon).tag(p)
                                .bold()
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                .fontWeight(.semibold)
                .fontWidth(.expanded)
                
                Section{
                    Toggle("Due Date", isOn: $hasDueDate)
                        .fontDesign(.monospaced)
                        .font(.system(size: 18))
                    if hasDueDate {
                        HStack {
                            Spacer()
                            DatePicker("", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .fontDesign(.monospaced)
                                .font(.system(size: 18))
                            Spacer()
                        }
                    }
                } header : {
                    Text("Schedule")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                }
                
                Section("Subtasks") {
                    HStack {
                        Image(systemName: "circle.dashed")
                            .font(.system(size: 23))
                            .foregroundColor(.secondary)
                        TextField("New subtask", text: $newSubtaskTitle)
                            .onSubmit {
                                addSubtask()
                            }
                            .font(.system(size: 18))
                            .fontDesign(.monospaced)
                            .fontWeight(.regular)
                        if !newSubtaskTitle.isEmpty {
                            Button(action: addSubtask) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(selectedAccent.color)
                            }
                        }
                    }
                    
                    ForEach($draftSubtasks) { $subtask in
                        HStack {
                            Button {
                                subtask.isCompleted.toggle()
                            } label: {
                                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                                    .font(.system(size: 23))
                                    .foregroundColor(subtask.isCompleted ? selectedAccent.color : .secondary)
                            }
                            .buttonStyle(.plain)
                            
                            TextField("Subtask", text: $subtask.title)
                                .fontDesign(.monospaced)
                                .font(.system(size: 18))
                                .strikethrough(subtask.isCompleted)
                                .foregroundColor(subtask.isCompleted ? .secondary : .primary)
                            
                            Button {
                                if let index = draftSubtasks.firstIndex(where: { $0.id == subtask.id }) {
                                    _ = withAnimation {
                                        draftSubtasks.remove(at: index)
                                    }
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red.opacity(0.8))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .onDelete { indexSet in
                        draftSubtasks.remove(atOffsets: indexSet)
                    }
                }
                .fontWeight(.semibold)
                .fontWidth(.expanded)
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.red)
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if task == nil {
                        Button("Add") {
                            saveTask()
                        }
                        .fontWeight(.semibold)
                        .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    } else {
                        Button("Save", systemImage: "checkmark") {
                            saveTask()
                        }
                        .fontWeight(.bold)
                        .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .withAppTheme()
        }
        .presentationDetents([.fraction(0.70)])
        .presentationDragIndicator(.hidden)
    }
    
    private func addSubtask() {
        let trimmed = newSubtaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            draftSubtasks.append(DraftSubtask(title: trimmed))
            newSubtaskTitle = ""
        }
    }
    
    private func saveTask() {
        let trimmed = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            onSave(trimmed, priority, hasDueDate ? dueDate : nil, draftSubtasks)
        }
        dismiss()
    }
}

#Preview {
    TaskFormView(onSave: { _, _, _, _ in })
        .withAppTheme()
}
