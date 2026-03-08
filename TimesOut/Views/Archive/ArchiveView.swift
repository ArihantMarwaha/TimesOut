import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.completedAt, order: .reverse) private var allTasks: [TaskItem]
    
    // Filter tasks that were completed more than 24 hours ago
    var archivedTasks: [TaskItem] {
        allTasks.filter { task in
            guard task.isCompleted, let completedAt = task.completedAt else { return false }
            // Check if 24 hours have passed since completion
            return Date().timeIntervalSince(completedAt) > 86400
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if archivedTasks.isEmpty {
                    ContentUnavailableView(
                        "No Archived Tasks",
                        systemImage: "archivebox",
                        description: Text("Tasks completed more than 24 hours ago will appear here.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(archivedTasks) { task in
                        TaskRow(
                            task: task,
                            isEditMode: false,
                            isSelected: false,
                            onToggle: {
                                // Un-archiving or un-completing
                                withAnimation {
                                    task.isCompleted = false
                                    task.completedAt = nil
                                    try? modelContext.save()
                                }
                            }
                        )
                        .listRowBackground(Color.clear)
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            for index in indexSet {
                                modelContext.delete(archivedTasks[index])
                            }
                            try? modelContext.save()
                        }
                    }
                }
            }
            .listStyle(.automatic)
            .navigationTitle("Archive")
        }
    }
}

#Preview {
    ArchiveView()
        .withAppTheme()
        .modelContainer(previewContainer)
}
