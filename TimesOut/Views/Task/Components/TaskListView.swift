import SwiftUI
import SwiftData

struct TaskListView: View {
    let tasks: [TaskItem]
    @Binding var isEditMode: Bool
    @Binding var selectedTaskIDs: Set<UUID>
    @Binding var taskToEdit: TaskItem?
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                TaskRow(
                    task: task,
                    isEditMode: isEditMode,
                    isSelected: selectedTaskIDs.contains(task.id),
                    onToggle: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            if isEditMode {
                                if selectedTaskIDs.contains(task.id) {
                                    selectedTaskIDs.remove(task.id)
                                } else {
                                    selectedTaskIDs.insert(task.id)
                                }
                            } else {
                                task.isCompleted.toggle()
                                try? modelContext.save()
                            }
                        }
                    },
                    onEdit: { taskToEdit = task }
                )
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.automatic)
    }
}

#Preview {
    TaskListView(
        tasks: [
            TaskItem(title: "Sample Task 1", priority: .high, dueDate: Date()),
            TaskItem(title: "Sample Task 2", priority: .medium)
        ],
        isEditMode: .constant(false),
        selectedTaskIDs: .constant([]),
        taskToEdit: .constant(nil)
    )
    .withAppTheme()
    .modelContainer(previewContainer)
}
