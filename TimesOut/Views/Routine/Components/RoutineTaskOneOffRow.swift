import SwiftUI

struct RoutineTaskOneOffRow: View {
    @Bindable var task: RoutineTask
    let accentColor: Color
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 12) {
            // Deadline Icon
            ZStack {
                Circle()
                    .fill(task.isCompleted ? accentColor.opacity(0.1) : Color.gray.opacity(0.1))
                Image(systemName: "timer")
                    .foregroundColor(task.isCompleted ? accentColor : .gray)
                    .font(.title3)
            }
            .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? .secondary : .primary)
                
                if let deadline = task.deadline {
                    Text("By \(timeFormatter.string(from: deadline))")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Completion Toggle
            Button {
                task.isCompleted.toggle()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(task.isCompleted ? accentColor : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let deadline = Calendar.current.date(byAdding: .hour, value: 2, to: Date())
    
    return List {
        RoutineTaskOneOffRow(
            task: RoutineTask(title: "Go to Gym", type: .oneOff, deadline: deadline),
            accentColor: .green
        )
        
        RoutineTaskOneOffRow(
            task: RoutineTask(title: "Take Vitamins", type: .oneOff, deadline: deadline, isCompleted: true),
            accentColor: .yellow
        )
    }
}
