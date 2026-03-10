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
    
    var body: some View {
        List {
            if tasks.isEmpty {
                ContentUnavailableView(
                    "No Tasks",
                    systemImage: "checklist",
                    description: Text("You have no tasks in this section.")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(tasks) { task in
                    TaskRow(
                        task: task,
                        isEditMode: isEditMode,
                        isSelected: selectedTaskIDs.contains(task.id),
                        onToggle: { handleToggle(task: task) },
                        onEdit: { taskToEdit = task }
                    )
                    .listRowBackground(Color.clear)
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
            TaskFormView { newTitle, newPriority, dueDate in
                // If a user is adding from the "Daily" section, we might want to default the date.
                // But TaskFormView handles its own internal Date state based on the optional TaskItem.
                // Let's just create it directly:
                let task = TaskItem(title: newTitle, priority: newPriority, dueDate: dueDate ?? defaultDueDate)
                modelContext.insert(task)
                try? modelContext.save()
            }
            .presentationDetents([.medium])
        }
        .sheet(item: $taskToEdit) { task in
            TaskFormView(task: task) { newTitle, newPriority, newDueDate in
                task.title = newTitle
                task.priority = newPriority
                task.dueDate = newDueDate
                try? modelContext.save()
            }
            .presentationDetents([.medium])
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
