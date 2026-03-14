import SwiftUI
import SwiftData

struct MainTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var tasks: [TaskItem]
    
    @State private var isAddingTask = false
    @State private var isEditMode = false
    @State private var selectedTaskIDs = Set<UUID>()
    @State private var taskToEdit: TaskItem? = nil
    
    var body: some View {
        NavigationStack {
            TaskListView(
                tasks: tasks,
                isEditMode: $isEditMode,
                selectedTaskIDs: $selectedTaskIDs,
                taskToEdit: $taskToEdit
            )
            .toolbarTitleDisplayMode(.inlineLarge)
            .navigationTitle("Tasks")
            .toolbar {
                TaskToolbar(
                    tasks: tasks,
                    isEditMode: $isEditMode,
                    selectedTaskIDs: $selectedTaskIDs,
                    isAddingTask: $isAddingTask
                )
            }
            .sheet(isPresented: $isAddingTask) {
                TaskFormView { title, priority, dueDate, draftSubtasks in
                    let newTask = TaskItem(title: title, priority: priority, dueDate: dueDate)
                    if !draftSubtasks.isEmpty {
                        newTask.subtasks = draftSubtasks.map { SubtaskItem(id: $0.id, title: $0.title, isCompleted: $0.isCompleted) }
                    }
                    modelContext.insert(newTask)
                    try? modelContext.save()
                }
                .withAppTheme()
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
                .withAppTheme()
            }
            .withAppTheme()
        }
    }
}

#Preview {
    MainTaskView()
        .withAppTheme()
        .modelContainer(previewContainer)
}
