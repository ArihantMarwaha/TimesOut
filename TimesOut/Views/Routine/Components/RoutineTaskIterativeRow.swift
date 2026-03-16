import SwiftUI

struct RoutineTaskIterativeRow: View {
    @Bindable var task: RoutineTask
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(accentColor.opacity(0.1), lineWidth: 4)
                Circle()
                    .trim(from: 0, to: CGFloat(task.currentCount) / CGFloat(task.targetCount))
                    .stroke(accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                
                Text("\(task.currentCount)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
            }
            .frame(width: 44, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                
                Text("Target: \(task.targetCount)")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Stepper Controls
            HStack(spacing: 15) {
                Button {
                    if task.currentCount > 0 {
                        task.currentCount -= 1
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundColor(accentColor.opacity(0.3))
                }
                .buttonStyle(.plain)
                
                Button {
                    if task.currentCount < task.targetCount {
                        task.currentCount += 1
                        if task.currentCount == task.targetCount {
                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                        } else {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    List {
        RoutineTaskIterativeRow(
            task: RoutineTask(title: "Drink Water", type: .iterative, targetCount: 8),
            accentColor: .blue
        )
        
        RoutineTaskIterativeRow(
            task: RoutineTask(title: "Read Pages", type: .iterative, targetCount: 20, currentCount: 15),
            accentColor: .orange
        )
    }
}
