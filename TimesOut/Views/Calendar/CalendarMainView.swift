import SwiftUI
import SwiftData

struct CalendarMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]
    
    @State private var viewModel = TaskDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 1. Calendar Bar
                    CalendarBarView(selectedDate: $viewModel.selectedDate)
                    
                    // 2. Daily Summary
                    DailySummaryBoxView(progress: viewModel.dailyProgress(from: allTasks))
                    
                    // 3. Daily Tasks Box
                    let daily = viewModel.dailyTasks(from: allTasks)
                    TaskSectionBoxView(
                        title: "Daily Tasks",
                        subtitle: viewModel.selectedDate.formatted(.dateTime.weekday().day()),
                        tasks: daily,
                        isEditMode: $viewModel.isEditMode,
                        selectedTaskIDs: $viewModel.selectedTaskIDs,
                        taskToEdit: $viewModel.taskToEdit
                    )
                    
                    // 4. Long Term Tasks Box
                    let longTerm = viewModel.longTermTasks(from: allTasks)
                    if !longTerm.isEmpty {
                        TaskSectionBoxView(
                            title: "Long Term",
                            subtitle: "Upcoming",
                            tasks: longTerm,
                            isEditMode: $viewModel.isEditMode,
                            selectedTaskIDs: $viewModel.selectedTaskIDs,
                            taskToEdit: $viewModel.taskToEdit
                        )
                    }
                    
                    // 5. Create Daily Routine Button placeholder
                    Button {
                        // Action for creating a routine
                    } label: {
                        HStack {
                            Image(systemName: "sparkles")
                            Text("Create Daily Routine")
                                .fontWeight(.bold)
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.gradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Dashboard")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                TaskToolbar(
                    tasks: allTasks,
                    isEditMode: $viewModel.isEditMode,
                    selectedTaskIDs: $viewModel.selectedTaskIDs,
                    isAddingTask: $viewModel.isAddingTask
                )
            }
            .sheet(isPresented: $viewModel.isAddingTask) {
                TaskFormView { title, priority, dueDate in
                    let newTask = TaskItem(title: title, priority: priority, dueDate: dueDate)
                    modelContext.insert(newTask)
                    try? modelContext.save()
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
                .withAppTheme()
            }
            .sheet(item: $viewModel.taskToEdit) { task in
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
        }
    }
}

#Preview {
    CalendarMainView()
        .withAppTheme()
        .modelContainer(previewContainer)
}
