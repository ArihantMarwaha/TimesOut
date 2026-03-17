import SwiftUI
import SwiftData

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<TaskItem> { $0.isArchived }, sort: \TaskItem.completedAt, order: .reverse) private var archivedTasks: [TaskItem]
    
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
                            isExpanded: .constant(false),
                            onToggle: {
                                // Un-archiving or un-completing
                                withAnimation {
                                    task.isCompleted = false
                                    task.completedAt = nil
                                    task.isArchived = false
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
            .navigationTitle("Archived Tasks")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
    }
}

#Preview {
    ArchiveView()
        .withAppTheme()
        .modelContainer(previewContainer)
}
