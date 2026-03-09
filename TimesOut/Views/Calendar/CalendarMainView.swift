import SwiftUI
import SwiftData

struct CalendarMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \TaskItem.createdAt, order: .reverse) private var allTasks: [TaskItem]
    
    @State private var viewModel = TaskDashboardViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                CalendarBarView(selectedDate: $viewModel.selectedDate)
                    .zIndex(1)
                // Scrollable Content layer
                ScrollView {
                    VStack(spacing: 24) {
                        // 2. Daily Summary
                        DailySummaryBoxView(progress: viewModel.dailyProgress(from: allTasks))
                            .padding(.top, 145) // Add padding so it starts below the floating calendar
                        
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
                        if !longTerm.isEmpty {
                            TaskSectionBoxView(
                                title: "Long Term",
                                subtitle: "Upcoming",
                                tasks: longTerm,
                                defaultDueDate: nil
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
                        .padding(.bottom, 40)
                    }
                }
                .background(Color(uiColor: .systemGroupedBackground))
                
                // 1. Calendar Bar (Fixed at top, floats over ScrollView)
              
            }
            .ignoresSafeArea(edges: .top) // Ignore safe area broadly here
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    CalendarMainView()
        .withAppTheme()
        .modelContainer(previewContainer)
}
