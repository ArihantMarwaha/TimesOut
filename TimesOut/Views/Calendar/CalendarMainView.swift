import SwiftUI
import SwiftData

struct CalendarMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]
    @Query(sort: \Routine.createdAt, order: .reverse) private var routines: [Routine]
    
    var viewModel: TaskDashboardViewModel
    
    var body: some View {
        @Bindable var viewModel = viewModel
        NavigationStack {
            ZStack(alignment: .top) {
                CalendarBarView(selectedDate: $viewModel.selectedDate)
                    .zIndex(1)
                // Scrollable Content layer
                ScrollView {
                    VStack(spacing: 24) {
                        // 2. Daily Summary
                        DailySummaryBoxView(progress: viewModel.dailyProgress(from: allTasks))
                            .padding(.top, 150)
                        
                        // 3. Daily Tasks Box
                        let daily = viewModel.dailyTasks(from: allTasks)
                        TaskSectionBoxView(
                            title: "Daily Tasks",
                            subtitle: viewModel.selectedDate.formatted(.dateTime.weekday().day()),
                            tasks: daily,
                            defaultDueDate: viewModel.selectedDate
                        )
                        
                        // 4. Long Term Tasks Box
                        let longTerm = viewModel.longTermTasks(from: allTasks)
                       // if !longTerm.isEmpty {
                            TaskSectionBoxView(
                                title: "Long Term",
                                subtitle: "Upcoming",
                                tasks: longTerm,
                                defaultDueDate: nil
                            )
                 //       }
                    }
                    .animation(.smooth(duration: 0.25), value: viewModel.selectedDate)
                }
                .background(Color(uiColor: .systemGroupedBackground))
            }
            .ignoresSafeArea(edges: .top)
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    CalendarMainView(viewModel: TaskDashboardViewModel())
        .withAppTheme()
        .modelContainer(previewContainer)
}
