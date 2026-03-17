import SwiftUI

struct RoutineFormView: View {
    let routine: Routine?
    // Callback now passes the properties needed to create/update a single Routine
    let onSave: (String, String, String, RoutineTaskType, Int, Date?, Date?, Date?) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    @State private var title: String
    @State private var icon: String
    @State private var accentColorEnum: AppAccentColor
    
    @State private var type: RoutineTaskType
    @State private var targetCount: Int
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var deadline: Date
    
    private let routineIcons = [
        "sun.max.fill", "moon.stars.fill", "cup.and.saucer.fill",
        "brain.head.profile", "heart.fill", "book.fill", 
        "briefcase.fill", "figure.run", "checklist",
        "tray.fill", "bed.double.fill", "clock.fill", "calendar",
        "bolt.fill", "star.fill", "flag.fill", "pills.fill",
        "laptopcomputer", "cart.fill", "house.fill"
    ]
    
    init(routine: Routine? = nil, onSave: @escaping (String, String, String, RoutineTaskType, Int, Date?, Date?, Date?) -> Void) {
        self.routine = routine
        self.onSave = onSave
        
        self._title = State(initialValue: routine?.title ?? "")
        self._icon = State(initialValue: routine?.icon ?? "sparkles")
        
        let initialAccent = AppAccentColor(rawValue: routine?.accentColor ?? "") ?? .yellow
        self._accentColorEnum = State(initialValue: initialAccent)
        
        self._type = State(initialValue: routine?.type ?? .oneOff)
        self._targetCount = State(initialValue: routine?.targetCount ?? 1)
        
        let now = Date()
        self._startTime = State(initialValue: routine?.startTime ?? Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: now) ?? now)
        self._endTime = State(initialValue: routine?.endTime ?? Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: now) ?? now)
        self._deadline = State(initialValue: routine?.deadline ?? Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? now)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                detailsSection
                accentColorSection
                configurationSection
            }
            .navigationTitle(routine == nil ? "New Routine" : "Edit Routine")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .fontWeight(.semibold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRoutine()
                    }
                    .fontWeight(.bold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .withAppTheme()
        }
        .presentationDetents([.large])
    }
    
    @ViewBuilder
    private var detailsSection: some View {
        Section {
            TextField("Routine Name (e.g. Drink Water)", text: $title)
                .font(.system(size: 20, weight: .semibold, design: .monospaced))
        } header: {
            Text("Routine Details")
                .fontWeight(.semibold)
                .fontWidth(.expanded)
        }
        
        RoutineIconPicker(icon: $icon, accentColor: currentAccentColor, icons: routineIcons)
    }
    
    @ViewBuilder
    private var accentColorSection: some View {
        Section {
            AccentSegmentedPicker(selectedAccent: $accentColorEnum)
                .padding(.vertical, 8)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
        } header: {
            Text("Accent Color")
                .fontWeight(.semibold)
                .fontWidth(.expanded)
        }
    }
    
    @ViewBuilder
    private var configurationSection: some View {
        Section("Task Behavior") {
            Picker("Type", selection: $type) {
                ForEach(RoutineTaskType.allCases, id: \.self) { taskType in
                    Label(taskType.description, systemImage: taskType.icon)
                        .tag(taskType)
                }
            }
            .pickerStyle(.menu)
            
            switch type {
            case .iterative:
                Stepper("Target: \(targetCount)", value: $targetCount, in: 1...100)
                    .fontDesign(.monospaced)
                
            case .interval:
                DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                    .fontDesign(.monospaced)
                DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                    .fontDesign(.monospaced)
                
            case .oneOff:
                DatePicker("Complete By", selection: $deadline, displayedComponents: .hourAndMinute)
                    .fontDesign(.monospaced)
            }
        }
        .fontWeight(.semibold)
        .fontWidth(.expanded)
    }
    
    private var currentAccentColor: Color {
        accentColorEnum.color
    }
    
    private func saveRoutine() {
        // Pass only the relevant dates based on the selected type to avoid saving junk data
        let finalStartTime = type == .interval ? startTime : nil
        let finalEndTime = type == .interval ? endTime : nil
        let finalDeadline = type == .oneOff ? deadline : nil
        let finalTargetCount = type == .iterative ? targetCount : 1
        
        onSave(title, icon, accentColorEnum.rawValue, type, finalTargetCount, finalStartTime, finalEndTime, finalDeadline)
        dismiss()
    }
}

#Preview {
    RoutineFormView { _, _, _, _, _, _, _, _ in }
        .withAppTheme()
}
