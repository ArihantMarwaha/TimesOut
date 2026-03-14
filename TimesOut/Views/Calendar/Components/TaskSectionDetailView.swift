import SwiftUI
import SwiftData

struct TaskSectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let title: String
    let subtitle: String?
    let tasks: [TaskItem]
    
    // Injected property for adding a new task (to pre-fill date if it's "Daily")
    var defaultDueDate: Date? = nil
    
    @State private var isEditMode = false
    @State private var selectedTaskIDs: Set<UUID> = []
    @State private var isAddingTask = false
    @State private var taskToEdit: TaskItem? = nil
    
    var sortedTasks: [TaskItem] {
        tasks.sorted {
            if $0.isCompleted != $1.isCompleted {
                return !$0.isCompleted && $1.isCompleted
            }
            if $0.priority.rawValue != $1.priority.rawValue {
                return $0.priority.rawValue > $1.priority.rawValue
            }
            return $0.createdAt > $1.createdAt
        }
    }
    
    @State private var expandedTaskIDs: Set<UUID> = []
    
    var body: some View {
        List {
            if sortedTasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks",
                    systemImage: "checklist",
                    description: Text("You have no tasks in this section.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(sortedTasks) { task in
                    let isExpandedBinding = Binding<Bool>(
                        get: { expandedTaskIDs.contains(task.id) },
                        set: { newValue in
                            if newValue {
                                expandedTaskIDs.insert(task.id)
                            } else {
                                expandedTaskIDs.remove(task.id)
                            }
                        }
                    )
                    
                    TaskRow(
                        task: task,
                        isEditMode: isEditMode,
                        isSelected: selectedTaskIDs.contains(task.id),
                        isExpanded: isExpandedBinding,
                        onToggle: { handleToggle(task: task) },
                        onEdit: { taskToEdit = task }
                    )
                    .listRowBackground(Color.clear)
                    
                    // Render subtasks as separate list rows
                    if expandedTaskIDs.contains(task.id),
                       let subtasks = task.subtasks, !subtasks.isEmpty {
                        let sorted = subtasks.sorted {
                            if $0.isCompleted != $1.isCompleted {
                                return !$0.isCompleted && $1.isCompleted
                            }
                            return $0.createdAt < $1.createdAt
                        }
                        ForEach(sorted) { subtask in
                            SubtaskRow(subtask: subtask, parentTask: task)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                
            }
            
        }
        .listStyle(.insetGrouped)
        .navigationTitle(title)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbar {
            TaskToolbar(
                tasks: tasks,
                isEditMode: $isEditMode,
                selectedTaskIDs: $selectedTaskIDs,
                isAddingTask: $isAddingTask
            )
        }
        .sheet(isPresented: $isAddingTask) {
            TaskFormView { newTitle, newPriority, dueDate, draftSubtasks in
                // If a user is adding from the "Daily" section, we might want to default the date.
                // We ensure it defaults to the end of the day (23:59:59) so it's not immediately overdue.
                let finalDueDate: Date?
                if let explicitDate = dueDate {
                    finalDueDate = explicitDate
                } else if let fallback = defaultDueDate {
                    finalDueDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: fallback) ?? fallback
                } else {
                    finalDueDate = nil
                }
                
                let task = TaskItem(title: newTitle, priority: newPriority, dueDate: finalDueDate)
                if !draftSubtasks.isEmpty {
                    task.subtasks = draftSubtasks.map { SubtaskItem(id: $0.id, title: $0.title, isCompleted: $0.isCompleted) }
                }
                modelContext.insert(task)
                try? modelContext.save()
            }
        }
        .sheet(item: $taskToEdit) { task in
            TaskFormView(task: task) { newTitle, newPriority, newDueDate, newDrafts in
                task.title = newTitle
                task.priority = newPriority
                task.dueDate = newDueDate
                
                // Reconcile subtasks
                let existingSubtasks = task.subtasks ?? []
                for draft in newDrafts {
                    if let existing = existingSubtasks.first(where: { $0.id == draft.id }) {
                        existing.title = draft.title
                        existing.isCompleted = draft.isCompleted
                    } else {
                        let newSubtask = SubtaskItem(id: draft.id, title: draft.title, isCompleted: draft.isCompleted)
                        if task.subtasks == nil { task.subtasks = [] }
                        task.subtasks?.append(newSubtask)
                    }
                }
                
                // Remove deleted subtasks
                let draftIDs = Set(newDrafts.map { $0.id })
                if let subtasks = task.subtasks {
                    for subtask in subtasks {
                        if !draftIDs.contains(subtask.id) {
                            modelContext.delete(subtask)
                            task.subtasks?.removeAll(where: { $0.id == subtask.id })
                        }
                    }
                }
                
                try? modelContext.save()
            }
        }
    }
    
    private func handleToggle(task: TaskItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if isEditMode {
                if selectedTaskIDs.contains(task.id) {
                    selectedTaskIDs.remove(task.id)
                } else {
                    selectedTaskIDs.insert(task.id)
                }
            } else {
                task.isCompleted.toggle()
                if task.isCompleted {
                    task.completedAt = Date()
                } else {
                    task.completedAt = nil
                }
                try? modelContext.save()
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskSectionDetailView(
            title: "Daily Tasks",
            subtitle: "Today",
            tasks: [TaskItem(title: "Sample Task", priority: .high)]
        )
    }
    .modelContainer(previewContainer)
    .withAppTheme()
}
