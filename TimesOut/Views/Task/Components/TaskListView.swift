import SwiftUI
import SwiftData

struct TaskListView: View {
    let tasks: [TaskItem]
    @Binding var isEditMode: Bool
    @Binding var selectedTaskIDs: Set<UUID>
    @Binding var taskToEdit: TaskItem?
    
    @State private var expandedTaskIDs = Set<UUID>()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List {
            ForEach(tasks) { task in
                Section {
                    TaskRow(
                        task: task,
                        isEditMode: isEditMode,
                        isSelected: selectedTaskIDs.contains(task.id),
                        isExpanded: Binding(
                            get: { expandedTaskIDs.contains(task.id) },
                            set: { isExpanded in
                                withAnimation {
                                    if isExpanded {
                                        expandedTaskIDs.insert(task.id)
                                    } else {
                                        expandedTaskIDs.remove(task.id)
                                    }
                                }
                            }
                        ),
                        onToggle: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                if isEditMode {
                                    if selectedTaskIDs.contains(task.id) {
                                        selectedTaskIDs.remove(task.id)
                                    } else {
                                        selectedTaskIDs.insert(task.id)
                                    }
                                } else {
                                    task.toggleCompletion()
                                    if task.isCompleted {
                                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                    }
                                    try? modelContext.save()
                                }
                            }
                        },
                        onEdit: { taskToEdit = task }
                    )
                    
                    if expandedTaskIDs.contains(task.id), let subtasks = task.subtasks {
                        ForEach(subtasks.sorted(by: { $0.createdAt < $1.createdAt })) { subtask in
                            SubtaskRow(subtask: subtask, parentTask: task)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }
                }
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
