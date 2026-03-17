import SwiftUI
internal import Combine

struct RoutineTaskIntervalRow: View {
    @Bindable var routine: Routine
    let accentColor: Color
    
    @State private var currentTime = Date()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        RoutineCard(title: routine.title, accentColor: accentColor) {
            // Visual Slot: Time Ring
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 4)
                
                Circle()
                    .trim(from: 0, to: CGFloat(max(0, min(1.0, progress))))
                    .stroke(
                        isWithinWindow ? accentColor.gradient : Color.gray.gradient,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                Image(systemName: routine.icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(isWithinWindow ? accentColor : .secondary)
            }
            .frame(width: 60, height: 60)
            .padding(10)
            
            Text(timeStatusText)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundColor(isWithinWindow ? accentColor : .secondary)
                .textCase(.uppercase)
        } footer: {
            // Footer Slot: Log Button
            Button {
                withAnimation {
                    routine.isCompleted.toggle()
                    routine.lastUpdatedDate = Date()
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
            } label: {
                Text(routine.isCompleted ? "Done" : "Log")
                    .font(.system(size: 12, weight: .bold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(routine.isCompleted ? accentColor : Color.primary.opacity(0.05))
                    .foregroundColor(routine.isCompleted ? .white : .primary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
    }
    
    private var progress: Double {
        guard let start = routine.startTime, let end = routine.endTime else { return 0 }
        let total = end.timeIntervalSince(start)
        let elapsed = currentTime.timeIntervalSince(start)
        return elapsed / total
    }
    
    private var isWithinWindow: Bool {
        guard let start = routine.startTime, let end = routine.endTime else { return false }
        return currentTime >= start && currentTime <= end
    }
    
    private var timeStatusText: String {
        guard let start = routine.startTime, let end = routine.endTime else { return "" }
        if currentTime < start { return "Coming Up" }
        if currentTime > end { return "Closed" }
        return "Active"
    }
}

#Preview {
    let now = Date()
    let calendar = Calendar.current
    
    let start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!
    let end = calendar.date(bySettingHour: 11, minute: 0, second: 0, of: now)!
    
    return List {
        RoutineTaskIntervalRow(
            routine: Routine(title: "Deep Work", type: .interval, startTime: start, endTime: end),
            accentColor: .purple
        )
        
        RoutineTaskIntervalRow(
            routine: Routine(title: "Coding Session", type: .interval, startTime: start, endTime: end, isCompleted: true),
            accentColor: .blue
        )
    }
}
