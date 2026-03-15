import SwiftUI

struct RoutineCard: View {
    let routine: Routine
    let isApplied: Bool
    var onApply: () -> Void
    
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    private var currentAccentColor: Color {
        AppAccentColor(rawValue: routine.accentColor)?.color ?? selectedAccent.color
    }
    
    var body: some View {
        Button {
            onApply()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(currentAccentColor.opacity(0.2))
                        Image(systemName: routine.icon)
                            .foregroundColor(currentAccentColor)
                            .font(.title2)
                    }
                    .frame(width: 50, height: 50)
                    
                    Spacer()
                    
                    Image(systemName: isApplied ? "checkmark.circle.fill" : "plus.circle.fill")
                        .font(.title2)
                        .offset(x:5,y:-15)
                        .foregroundColor(isApplied ? .white : .primary)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(routine.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .fontWidth(.expanded)
                    
                    Text("\(routine.tasks?.count ?? 0) Tasks")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(isApplied ? .white.opacity(0.8) : .secondary)
                }
                .foregroundColor(isApplied ? .white : .primary)
            }
            .padding(20)
            .frame(width: 170, height: 200)
            .contentShape(Rectangle())
            .background {
                ZStack {
                    if isApplied {
                        currentAccentColor.opacity(0.2)
                    } else {
                        Color.clear
                    }
                }
                .cornerRadius(35)
            }
            .glassEffect(.clear.interactive(true).tint(isApplied ? currentAccentColor : .clear), in: .rect(cornerRadius: 35))
            .shadow(color: isApplied ? currentAccentColor.opacity(0.2) : .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        RoutineCard(routine: Routine(title: "Morning Routine", icon: "sun.max.fill", accentColor: "orange"), isApplied: false) {
            print("Apply routine")
        }
    }
    .withAppTheme()
}
