import SwiftUI
import SwiftData

struct TaskSectionBoxView: View {
    let title: String
    let subtitle: String?
    let tasks: [TaskItem]
    
    @Binding var isEditMode: Bool
    @Binding var selectedTaskIDs: Set<UUID>
    @Binding var taskToEdit: TaskItem?
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.bold)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 2)
                }
                
                Spacer()
                
                Text("\(tasks.filter { $0.isCompleted }.count)/\(tasks.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(selectedAccent.color.opacity(0.2))
                    .foregroundColor(selectedAccent.color)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            if tasks.isEmpty {
                Text("No tasks here.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                VStack(spacing: 8) {
                    ForEach(tasks) { task in
                        TaskRow(
                            task: task,
                            isEditMode: isEditMode,
                            isSelected: selectedTaskIDs.contains(task.id),
                            onToggle: {
                                handleToggle(task: task)
                            },
                            onEdit: { taskToEdit = task }
                        )
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        
                        if task.id != tasks.last?.id {
                            Divider()
                                .padding(.leading, 50)
                        }
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.5))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
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
    TaskSectionBoxView(
        title: "Daily Tasks",
        subtitle: "Today",
        tasks: [
            TaskItem(title: "Preview Task", priority: .high)
        ],
        isEditMode: .constant(false),
        selectedTaskIDs: .constant([]),
        taskToEdit: .constant(nil)
    )
    .padding(.vertical)
    .withAppTheme()
    .modelContainer(previewContainer)
}
