import SwiftUI

struct RoutineTaskOneOffRow: View {
    @Bindable var routine: Routine
    let accentColor: Color
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                routine.isCompleted.toggle()
                routine.lastUpdatedDate = Date()
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        } label: {
            RoutineCard(title: routine.title, accentColor: accentColor) {
                // Visual Slot: Icon Header
                ZStack {
                    Circle()
                        .fill(routine.isCompleted ? Color.gray.opacity(0.1) : accentColor.opacity(0.1))
                    
                    Image(systemName: routine.icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(routine.isCompleted ? .secondary : accentColor)
                }
                .frame(width: 60, height: 60)
                .padding(.top,20)
                
                Text(routine.isCompleted ? "Completed" : "Tap to Log")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(routine.isCompleted ? .green : .secondary)
                    .padding(-25)
                    .padding(.bottom,-30)
            } footer: {
                // Footer Slot: Status Bar
                Capsule()
                    .fill(routine.isCompleted ? Color.green : Color.gray.opacity(0.1))
                    .frame(height: 6)
                    .padding(.top, -10)
                    .padding(.bottom, 8)
                    .padding(.horizontal,30)
            }
        }
        .buttonStyle(SquishButtonStyle())
    }
}
#Preview {
    ZStack {
        Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
        
        RoutineTaskOneOffRow(
            routine: Routine(
                title: "Call Mom",
                icon: "phone.fill",
                accentColor: AppAccentColor.pink.rawValue,
                type: .oneOff,
                deadline: Date()
            ),
            accentColor: .pink
        )
        .padding()
    }
}
