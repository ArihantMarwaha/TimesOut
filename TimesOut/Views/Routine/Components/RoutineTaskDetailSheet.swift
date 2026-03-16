import SwiftUI

struct RoutineTaskDetailSheet: View {
    @Binding var task: DraftRoutineTask
    let accentColor: Color
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Task Title") {
                    TextField("Title", text: $task.title)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                }
                
                Section("Task Type") {
                    Picker("Type", selection: $task.type) {
                        ForEach(RoutineTaskType.allCases, id: \.self) { type in
                            Label(type.description, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Type-Specific Sections
                switch task.type {
                case .oneOff:
                    Section("Deadline") {
                        DatePicker("Complete By", selection: Binding(
                            get: { task.deadline ?? Date() },
                            set: { task.deadline = $0 }
                        ), displayedComponents: .hourAndMinute)
                    }
                    
                case .interval:
                    Section("Time Window") {
                        DatePicker("Start Time", selection: Binding(
                            get: { task.startTime ?? Date() },
                            set: { task.startTime = $0 }
                        ), displayedComponents: .hourAndMinute)
                        
                        DatePicker("End Time", selection: Binding(
                            get: { task.endTime ?? Date() },
                            set: { task.endTime = $0 }
                        ), displayedComponents: .hourAndMinute)
                    }
                    
                case .iterative:
                    Section("Repetitions") {
                        Stepper("Target: \(task.targetCount)", value: $task.targetCount, in: 1...100)
                    }
                }
            }
            .navigationTitle("Configure Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.bold)
                }
            }
            .withAppTheme()
        }
    }
}

#Preview {
    RoutineTaskDetailSheet(
        task: .constant(DraftRoutineTask(title: "Morning Routine", type: .iterative, targetCount: 5)),
        accentColor: .blue
    )
}
