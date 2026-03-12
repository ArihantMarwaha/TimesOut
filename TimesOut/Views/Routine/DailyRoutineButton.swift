import SwiftUI

struct DailyRoutineButton: View {
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                Spacer()
                
                // Main Button Content Layer (Circular icon)
                ZStack {
                    // Inner bordered circle containing the gradient
                    Circle()
                        .strokeBorder(Color.white.opacity(1), lineWidth: 1)
                        // The clear circle makes room for the background behind it
                        .background(
                            Circle()
                                .fill(Color.clear)
                                .background(
                                    ButtonGradient()
                                        .frame(height: 80)
                                        .clipShape(Circle())
                                )
                                .overlay{
                                    Circle()
                                        .fill(Color.clear)
                                        .glassEffect(.clear)
                                        .frame(width: 80, height: 80)
                                }
                        )
                        .frame(width:75, height:70)
                    
                    // Icon on top
                    Image(systemName: "plus")
                        .font(.system(size: 34, weight: .light))
                        .foregroundStyle(Color.primary.opacity(0.6))
                }
                
                Text("Make Routine")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .fontWidth(.expanded)
                    .foregroundStyle(Color.primary)
                
                Spacer()
            }
            .padding(.vertical)
            .background(Color.clear)
            .contentShape(Rectangle()) // Ensures the whole clear rectangle is tappable
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea() // To see the white opacities clearly
        DailyRoutineButton(action: {})
            .withAppTheme()
    }
}
