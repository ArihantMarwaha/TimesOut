import SwiftUI

struct RoutineTaskIntervalRow: View {
    @Bindable var task: RoutineTask
    let accentColor: Color
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 12) {
            // Time Window Indicator
            ZStack {
                Circle()
                    .fill(isWithinWindow ? accentColor.opacity(0.1) : Color.gray.opacity(0.1))
                Image(systemName: "clock.badge.checkmark")
                    .foregroundColor(isWithinWindow ? accentColor : .gray)
                    .font(.title3)
            }
            .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                
                HStack(spacing: 4) {
                    Text(timeFormatter.string(from: task.startTime ?? Date()))
                    Text("-")
                    Text(timeFormatter.string(from: task.endTime ?? Date()))
                }
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
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
    
    private var isWithinWindow: Bool {
        let now = Date()
        guard let start = task.startTime, let end = task.endTime else { return false }
        
        let calendar = Calendar.current
        let componentsNow = calendar.dateComponents([.hour, .minute], from: now)
        let componentsStart = calendar.dateComponents([.hour, .minute], from: start)
        let componentsEnd = calendar.dateComponents([.hour, .minute], from: end)
        
        guard let dateNow = calendar.date(from: componentsNow),
              let dateStart = calendar.date(from: componentsStart),
              let dateEnd = calendar.date(from: componentsEnd) else { return false }
              
        return dateNow >= dateStart && dateNow <= dateEnd
    }
}

#Preview {
    let now = Date()
    let calendar = Calendar.current
    
    let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
    let end = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: now)!
    
    return List {
        RoutineTaskIntervalRow(
            task: RoutineTask(title: "Deep Work", type: .interval, startTime: start, endTime: end),
            accentColor: .purple
        )
        
        RoutineTaskIntervalRow(
            task: RoutineTask(title: "Coding Session", type: .interval, startTime: start, endTime: end, isCompleted: true),
            accentColor: .blue
        )
    }
}
