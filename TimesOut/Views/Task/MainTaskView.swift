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
            ScrollView {
                VStack(spacing: 24) {
                    // 2. The Regular Tasks List
                    TaskListView(
                        tasks: tasks,
                        isEditMode: $isEditMode,
                        selectedTaskIDs: $selectedTaskIDs,
                        taskToEdit: $taskToEdit
                    )
                }
                .padding(.bottom, 30)
            }
            .background(Color(uiColor: .systemGroupedBackground))
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
                    modelContext.insert(newTask)
                    
                    if !draftSubtasks.isEmpty {
                        newTask.subtasks = draftSubtasks.map { 
                            let sub = SubtaskItem(id: $0.id, title: $0.title, isCompleted: $0.isCompleted)
                            sub.parentTask = newTask
                            return sub
                        }
                    }
                    try? modelContext.save()
                }
                .withAppTheme()
            }
            .sheet(item: $taskToEdit) { task in
                TaskFormView(task: task) { newTitle, newPriority, newDueDate, newDrafts in
                    task.update(
                        title: newTitle,
                        priority: newPriority,
                        dueDate: newDueDate,
                        draftSubtasks: newDrafts,
                        context: modelContext
                    )
                    try? modelContext.save()
                }
                .withAppTheme()
            }
            .withAppTheme()
        }
        //main task view ends here
    }
}

#Preview {
    MainTaskView()
        .withAppTheme()
        .modelContainer(previewContainer)
}
