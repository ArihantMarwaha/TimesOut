import SwiftUI
import SwiftData

struct TaskSectionBoxView: View {
    let title: String
    let subtitle: String?
    let tasks: [TaskItem]
    
    // Properties for Detail View navigation
    var defaultDueDate: Date? = nil
    
    @Environment(\.modelContext) private var modelContext
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    // The Box will show up to 2 tasks.
    // Prioritize unfinished tasks. If there are fewer than 2 unfinished, fill the rest with completed.
    private var displayTasks: [TaskItem] {
        let unfinished = tasks.filter { !$0.isCompleted }
        if unfinished.count >= 2 {
            return Array(unfinished.prefix(2))
        } else {
            let completed = tasks.filter { $0.isCompleted }
            let combined = unfinished + completed
            return Array(combined.prefix(2))
        }
    }
    
    private var unfinishedCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    var body: some View {
        NavigationLink {
            // Push to the new Detail Workspace
            TaskSectionDetailView(
                title: title,
                subtitle: subtitle,
                tasks: tasks,
                defaultDueDate: defaultDueDate
            )
        } label: {
            // Summary Card UI
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .bottom) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 2)
                    }
                    
                    Spacer()
                    
                    // Ratio of completed / total
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
                    Text("All caught up!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(displayTasks) { task in
                            TaskRow(
                                task: task,
                                isEditMode: false,
                                isSelected: false,
                                onToggle: {
                                    handleToggle(task: task)
                                },
                                onEdit: {}
                            )
                            .padding(.vertical, 4)
                            .padding(.horizontal, 16)
                            // Prevent the TaskRow tap from triggering the NavigationLink, if necessary,
                            // although buttons inside NavigationLinks usually take priority in SwiftUI.
                        }
                        
                        // Indicate more hidden tasks
                        if unfinishedCount > 2 {
                            Text("+ \(unfinishedCount - 2) more to do")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                        } else if tasks.count > 2 {
                            Text("+ \(tasks.count - 2) more completed")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.5))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
        }
        .buttonStyle(.plain) // Prevent entire card from looking like a default list button
    }
    
    private func handleToggle(task: TaskItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
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

#Preview {
    NavigationStack {
        TaskSectionBoxView(
            title: "Daily Tasks",
            subtitle: "Today",
            tasks: [
                TaskItem(title: "Sample Task 1", priority: .high),
                TaskItem(title: "Sample Task 2", priority: .medium)
            ]
        )
    }
    .padding(.vertical)
    .withAppTheme()
    .modelContainer(previewContainer)
}
