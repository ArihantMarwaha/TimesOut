import SwiftUI

struct RoutineTaskIterativeRow: View {
    @Bindable var routine: Routine
    let accentColor: Color
    
    var body: some View {
        RoutineCard(title: routine.title, accentColor: accentColor) {
            // Visual Slot: Interactive Ring
            Button {
                logProgress()
            } label: {
                ZStack {
                    Circle()
                        .trim(from: 0.150, to: 0.850)
                        .stroke(accentColor.opacity(0.1), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(90))
                    
                    Circle()
                        .trim(from: 0.150, to: 0.150 + (0.70 * CGFloat(routine.currentCount) / CGFloat(routine.targetCount)))
                        .stroke(
                            accentColor.gradient,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(90))
                        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: routine.currentCount)
                    
                    VStack(spacing: 0) {
                        Image(systemName: routine.icon)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(accentColor)
                        
                        Text("\(routine.currentCount)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .contentTransition(.numericText())
                    }
                }
                .padding(.top, 10)
                .glassEffect(.regular, in: .circle)
                .shadow(color: accentColor.opacity(0.15), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(SquishButtonStyle())
        } footer: {
            // Footer Slot: Status
            Text("\(routine.currentCount) / \(routine.targetCount)")
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(.secondary)
                .contentTransition(.numericText())
                .padding(.bottom, 8)
        }
    }
    
    
    private func logProgress() {
        guard routine.currentCount < routine.targetCount else {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            return
        }
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            routine.currentCount += 1
            routine.lastUpdatedDate = Date()
            if routine.currentCount == routine.targetCount {
                routine.isCompleted = true
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            } else {
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
}

struct SquishButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.interactiveSpring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

#Preview {
    List {
        RoutineTaskIterativeRow(
            routine: Routine(title: "Drink Water", type: .iterative, targetCount: 8),
            accentColor: .blue
        )
        
        RoutineTaskIterativeRow(
            routine: Routine(title: "Read Pages", type: .iterative, targetCount: 20, currentCount: 15),
            accentColor: .orange
        )
    }
}
