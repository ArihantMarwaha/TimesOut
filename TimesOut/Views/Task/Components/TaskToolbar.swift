import SwiftUI
import SwiftData

struct TaskToolbar: ToolbarContent {
    let tasks: [TaskItem]
    @Binding var isEditMode: Bool
    @Binding var selectedTaskIDs: Set<UUID>
    @Binding var isAddingTask: Bool
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some ToolbarContent {
        if !isEditMode {
            ToolbarItem {
                Button("Edit") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditMode.toggle()
                        if !isEditMode { selectedTaskIDs.removeAll() }
                    }
                }
                .foregroundStyle(Color.primary)
                .bold()
            }
        } else {
            ToolbarItem {
                Button("Done") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditMode.toggle()
                        if !isEditMode { selectedTaskIDs.removeAll() }
                    }
                }
                .buttonStyle(.glassProminent)
                .bold()
            }
        }
        
        // This is a custom element observed in the Main app
        ToolbarSpacer()
        
        ToolbarItem {
            if isEditMode {
                Button {
                    withAnimation {
                        // Delete selected tasks from SwiftData
                        for task in tasks where selectedTaskIDs.contains(task.id) {
                            modelContext.delete(task)
                        }
                        try? modelContext.save()
                        selectedTaskIDs.removeAll()
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(selectedTaskIDs.isEmpty ? .gray : .red)
                }
                .disabled(selectedTaskIDs.isEmpty)
            } else {
                Button { isAddingTask = true } label: {
                    Image(systemName: "plus")
                        .fontWeight(.bold)
                }
            }
        }
    }
}

// Ensure ToolbarSpacer compiles correctly if it's not natively accessible
// or if the user used it inside ContentView, it will work here for ToolbarContent too.

struct TaskToolbar_PreviewWrapper: View {
    @State private var isEditMode = false
    @State private var selectedTaskIDs = Set<UUID>()
    @State private var isAddingTask = false
    
    var body: some View {
        NavigationStack {
            Text("Preview Toolbar")
                .toolbar {
                    TaskToolbar(
                        tasks: [],
                        isEditMode: $isEditMode,
                        selectedTaskIDs: $selectedTaskIDs,
                        isAddingTask: $isAddingTask
                    )
                }
        }
    }
}

#Preview {
    TaskToolbar_PreviewWrapper()
        .withAppTheme()
        .modelContainer(previewContainer)
}
