import SwiftUI

struct TaskFormView: View {
    let task: TaskItem?
    let onSave: (String, TaskPriority, Date?) -> Void
    
    @State private var editedTitle: String
    @State private var priority: TaskPriority
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    init(task: TaskItem? = nil, onSave: @escaping (String, TaskPriority, Date?) -> Void) {
        self.task = task
        self.onSave = onSave
        self._editedTitle = State(initialValue: task?.title ?? "")
        self._priority = State(initialValue: task?.priority ?? .medium)
        self._hasDueDate = State(initialValue: task?.dueDate != nil)
        self._dueDate = State(initialValue: task?.dueDate ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task title", text: $editedTitle)
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
                    Toggle("Has Due Date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
   
                    }
                } header : {
                    Text("Schedule")
                        .fontWeight(.semibold)
                        .fontWidth(.expanded)
                }
            }
            .navigationTitle(task == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .fontWeight(.semibold)
                    if task == nil {
                        // .buttonStyle(.glassProminent) compilation fails as it requires the button to have it.
                        // Can't apply conditionally without an external modifier or AnyView easily.
                        // Let's just apply it unconditionally or conditionally via a wrapper block?
                        // Actually, I can just not apply it, or apply it if it looks good on both.
                        // Wait, let's keep it simple and just do it correctly. 
                    }
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
    }
    
    private func saveTask() {
        let trimmed = editedTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            onSave(trimmed, priority, hasDueDate ? dueDate : nil)
        }
        dismiss()
    }
}

#Preview {
    TaskFormView(onSave: { _, _, _ in })
        .withAppTheme()
}
