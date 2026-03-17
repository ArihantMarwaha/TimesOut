import SwiftUI
import SwiftData

struct RoutineView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Routine.createdAt, order: .reverse) private var routines: [Routine]
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    @State private var isShowingForm = false
    @State private var routineToEdit: Routine? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        // Top Section: Make New Routine
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Start Fresh")
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontWidth(.expanded)
                                .padding(.horizontal)
                                
                            DailyRoutineButton {
                                isShowingForm = true
                            }
                        }
                        .padding(.top, 20)
                        
                        // Main Section: Active Interactive Routines Grid
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Your Routines")
                                .font(.title3)
                                .fontWeight(.bold)
                                .fontWidth(.expanded)
                                .padding(.horizontal)
                            
                            if routines.isEmpty {
                                Text("No routines yet. Tap 'Make Routine' above to get started.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)
                            } else {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 16) {
                                    ForEach(routines) { routine in
                                        routineRow(for: routine)
                                            .contextMenu {
                                                Button {
                                                    routineToEdit = routine
                                                } label: {
                                                    Label("Edit", systemImage: "pencil")
                                                }
                                                
                                                Button(role: .destructive) {
                                                    withAnimation {
                                                        modelContext.delete(routine)
                                                        try? modelContext.save()
                                                    }
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                }
            }
            .navigationTitle("Routines")
            .toolbarTitleDisplayMode(.inlineLarge)
            .onAppear {
                checkAndResetDailyRoutines()
            }
            .sheet(isPresented: $isShowingForm) {
                RoutineFormView { title, icon, accent, type, targetCount, startTime, endTime, deadline in
                    let newRoutine = Routine(
                        title: title,
                        icon: icon,
                        accentColor: accent,
                        type: type,
                        deadline: deadline,
                        startTime: startTime,
                        endTime: endTime,
                        targetCount: targetCount
                    )
                    modelContext.insert(newRoutine)
                    try? modelContext.save()
                }
            }
            .sheet(item: $routineToEdit) { routine in
                RoutineFormView(routine: routine) { title, icon, accent, type, targetCount, startTime, endTime, deadline in
                    routine.title = title
                    routine.icon = icon
                    routine.accentColor = accent
                    routine.type = type
                    routine.targetCount = targetCount
                    routine.startTime = startTime
                    routine.endTime = endTime
                    routine.deadline = deadline
                    
                    try? modelContext.save()
                }
            }
        }
    }
    
    // Dynamically render the correct row type based on the Routine's enum type
    @ViewBuilder
    private func routineRow(for routine: Routine) -> some View {
        let color = AppAccentColor(rawValue: routine.accentColor)?.color ?? .gray
        
        switch routine.type {
        case .interval:
            RoutineTaskIntervalRow(routine: routine, accentColor: color)
        case .iterative:
            RoutineTaskIterativeRow(routine: routine, accentColor: color)
        case .oneOff:
            RoutineTaskOneOffRow(routine: routine, accentColor: color)
        }
    }
    
    /// The critical Daily Reset logic.
    /// Checks if a routine's `lastUpdatedDate` is from a previous day. If so, resets its progress.
    private func checkAndResetDailyRoutines() {
        let calendar = Calendar.current
        var needsSave = false
        
        for routine in routines {
            if !calendar.isDateInToday(routine.lastUpdatedDate) {
                // It's a new day! Reset the interactive states
                routine.isCompleted = false
                routine.currentCount = 0
                routine.lastUpdatedDate = Date()
                needsSave = true
            }
        }
        
        if needsSave {
            try? modelContext.save()
        }
    }
}

#Preview {
    RoutineView()
        .withAppTheme()
        .modelContainer(previewContainer)
}
