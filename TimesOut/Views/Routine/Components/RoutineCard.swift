import SwiftUI

struct RoutineCard<Visual: View, Footer: View>: View {
    let title: String
    let accentColor: Color
    @ViewBuilder let visual: Visual
    @ViewBuilder let footer: Footer
    
    var body: some View {
        VStack(spacing: 8) {
            // Top Visual Area
            visual
                .frame(maxWidth: .infinity)
                .padding()
            
            
            // Middle Title Area
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .fontWidth(.expanded)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 4)
            
            // Bottom Footer/Action Area
            footer
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .glassEffect(.regular.interactive(),in:.rect(cornerRadius:25))
        .background {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.clear)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
}
#Preview {
    ZStack {
       Color(uiColor: .systemGroupedBackground).ignoresSafeArea()
        
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            RoutineCard(title: "Morning Coffee", accentColor: .brown) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.brown)
            } footer: {
                Text("Log Progress")
                    .font(.caption)
                    .padding(.bottom, 8)
            }
            
            RoutineCard(title: "Read 10 Pages", accentColor: .blue) {
                Circle()
                    .stroke(Color.blue.opacity(0.1), lineWidth: 4)
                    .overlay(
                        Image(systemName: "book.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    )
                    .frame(width: 60, height: 60)
            } footer: {
                Capsule()
                    .fill(Color.blue)
                    .frame(height: 4)
                    .padding(.bottom, 8)
            }
        }
        .padding()
    }
}
