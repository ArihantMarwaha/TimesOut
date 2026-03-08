import SwiftUI
import SwiftData

struct ContentView: View {
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
                TaskFormView { title, priority, dueDate in
                    let newTask = TaskItem(title: title, priority: priority, dueDate: dueDate)
                    modelContext.insert(newTask)
                    try? modelContext.save()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .withAppTheme()
            }
            .sheet(item: $taskToEdit) { task in
                TaskFormView(task: task) { newTitle, newPriority, newDueDate in
                    task.title = newTitle
                    task.priority = newPriority
                    task.dueDate = newDueDate
                    try? modelContext.save()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .withAppTheme()
            }
            .withAppTheme()
        }
    }
}

#Preview {
    ContentView()
        .withAppTheme()
        .modelContainer(previewContainer)
}
