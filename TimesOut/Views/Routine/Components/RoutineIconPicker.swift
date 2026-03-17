import SwiftUI

struct RoutineIconPicker: View {
    @Binding var icon: String
    let accentColor: Color
    let icons: [String]
    
    @State private var currentIconID: String?
    
    var body: some View {
        Section {
            GeometryReader { geometry in
                let itemSize: CGFloat = 70
                
                ZStack {
                    // Background Selection Box
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(accentColor.opacity(0.1))
                        .glassEffect(.clear.tint(accentColor.opacity(0.1)), in: .rect(cornerRadius: 20))
                        .frame(width: itemSize + 12, height: itemSize + 12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .strokeBorder(accentColor.opacity(0.4), lineWidth: 2)
                        )
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 20) {
                            ForEach(icons, id: \.self) { iconName in
                                Image(systemName: iconName)
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(icon == iconName ? accentColor : .secondary)
                                    .frame(width: itemSize, height: itemSize)
                                    .id(iconName)
                                    .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                        content
                                            .scaleEffect(phase.isIdentity ? 1.2 : 0.85)
                                            .opacity(phase.isIdentity ? 1.0 : 0.4)
                                            .blur(radius: phase.isIdentity ? 0 : 1)
                                    }
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $currentIconID, anchor: .center)
                    .scrollTargetBehavior(.viewAligned)
                    .contentMargins(.horizontal, (geometry.size.width - itemSize) / 2, for: .scrollContent)
                    .scrollClipDisabled()
                }
           
            }
            .frame(height: 110)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        } header: {
            Text("Routine Icon")
                .fontWeight(.semibold)
                .fontWidth(.expanded)
        }
        .onChange(of: currentIconID) { _, newValue in
            if let newValue, icon != newValue {
                withAnimation(.snappy(duration: 0.2)) {
                    icon = newValue
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
        .onAppear {
            if currentIconID == nil {
                currentIconID = icon
            }
        }
    }
}

#Preview {
    Form {
        RoutineIconPicker(
            icon: .constant("sun.max.fill"),
            accentColor: .orange,
            icons: ["sun.max.fill", "moon.stars.fill", "cup.and.saucer.fill", "brain.head.profile", "heart.fill"]
        )
    }
    .withAppTheme()
}
