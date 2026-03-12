import SwiftUI

struct ButtonGradient: View {
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    @State private var rotation: Double = 0
    
    private var opposingColor: Color {
        switch selectedAccent {
        case .yellow: return .purple
        case .blue: return .orange
        case .pink: return .green
        case .purple: return .yellow
        case .orange: return .cyan
        case .green: return .pink
        }
    }
    
    // Add a tertiary blending color for increased mesh complexity
    private var tertiaryColor: Color {
        switch selectedAccent {
        case .yellow: return .pink
        case .blue: return .purple
        case .pink: return .orange
        case .purple: return .blue
        case .orange: return .yellow
        case .green: return .cyan
        }
    }
    
    var body: some View {
        ZStack {
//             Base Gradient Mesh
//             Add a slight black tint to darken the accent colors for better white icon contrast
//            LinearGradient(
//                colors: [
//                    selectedAccent.color.opacity(0.8),
//                    selectedAccent.color.opacity(0.9),
//                    .black.opacity(0.4)
//                ],
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            
            // Primary Opposing Color Orb (Orbital movement)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [opposingColor, opposingColor.opacity(0.6), .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .offset(x: 20, y: -30)
                // Orbital rotation
                .rotationEffect(.degrees(rotation))
            
            // Tertiary Color Orb (Counter-rotating movement)
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [tertiaryColor.opacity(0.8), tertiaryColor.opacity(0.5), .clear]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 70
                    )
                )
                .frame(width: 140, height: 140)
                .offset(x: -25, y: 30)
                // Counter-orbit spin, slightly faster
                .rotationEffect(.degrees(-rotation * 1.5))
                .blendMode(.plusLighter) // Using plusLighter here is okay since the base is darker now
            
            // Core Pulsating Hotspot (Softened the white to black/gray for depth instead of brightness)
            //            Circle()
            //                .fill(
            //                    RadialGradient(
            //                        gradient: Gradient(colors: [.black.opacity(0.3), .clear]),
            //                        center: .center,
            //                        startRadius: 0,
            //                        endRadius: 40
            //                    )
            //                )
            //                .frame(width: 80, height: 80)
            //                .scaleEffect(1.0 + (sin(rotation * .pi / 180) * 0.4))
            //                .blendMode(.overlay)
            
            // Dynamic Angular Gradient overlay (Darkened shadows, reduced white highlights)
            //            AngularGradient(
            //                gradient: Gradient(colors: [
            //                    .black.opacity(0.4),
            //                    .clear,
            //                    selectedAccent.color.opacity(1),
            //                    .black.opacity(0.6),
            //                    .clear,
            //                    .black.opacity(0.4)
            //                ]),
            //                center: .center,
            //                angle: .degrees(rotation)
            //            )
            //            .blendMode(.overlay)
            
            // Diagonal Glassy Rim Light (Darkened)
            //            LinearGradient(
            //                colors: [.white.opacity(0.2), .clear, .black.opacity(0.5)],
            //                startPoint: .topLeading,
            //                endPoint: .bottomTrailing
            //            )
            //            .blendMode(.overlay)
            //
            //            // Top highlight for a "glassy" edge
            //            LinearGradient(
            //                colors: [.black.opacity(0.7), .clear],
            //                startPoint: .top,
            //                endPoint: .bottom
            //            )
            //            .blendMode(.softLight)
        }
        .background{
            Color.black.opacity(0.4)
        }
        .onAppear {
            withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

#Preview {
    ButtonGradient()
        .withAppTheme()
        .frame(height: 65)
        .clipShape(Circle())
        .padding()
}
