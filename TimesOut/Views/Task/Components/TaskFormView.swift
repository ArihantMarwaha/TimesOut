import SwiftUI

struct TaskFormView: View {
    let task: TaskItem?
    let onSave: (String, TaskPriority, Date?, [DraftSubtask]) -> Void
    
    @State private var editedTitle: String
    @State private var priority: TaskPriority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @State private var draftSubtasks: [DraftSubtask]
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    init(task: TaskItem? = nil, onSave: @escaping (String, TaskPriority, Date?, [DraftSubtask]) -> Void) {
        self.task = task
        self.onSave = onSave
        self._editedTitle = State(initialValue: task?.title ?? "")
        self._priority = State(initialValue: task?.priority ?? .medium)
        self._hasDueDate = State(initialValue: task?.dueDate != nil)
        
        let initialDate = task?.dueDate ?? Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
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
                    Text(task != nil ? "Task Name" : "Task Details")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                }
                
                Section("Priority") {
                    PriorityPicker(selection: $priority)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 8)
                }
                .fontWeight(.semibold)
                .fontWidth(.expanded)
                
                Section {
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
                    SubtaskListView<DraftSubtask>.forTasks(subtasks: $draftSubtasks, accentColor: selectedAccent.color)
                        .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .fontWeight(.semibold)
                .fontWidth(.expanded)
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .buttonStyle(.glassProminent)
                        .tint(.red)
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(task == nil ? "Add" : "Save") {
                        saveTask()
                    }
                    .fontWeight(.bold)
                    .disabled(editedTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .withAppTheme()
        }
        .presentationDetents([.fraction(0.85)])
        .presentationDragIndicator(.visible)
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
