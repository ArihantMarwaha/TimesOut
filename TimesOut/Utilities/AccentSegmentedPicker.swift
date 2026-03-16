import SwiftUI

struct AccentSegmentedPicker: View {
    @Binding var selectedAccent: AppAccentColor
    @Namespace private var animation
    @State private var localAccent: AppAccentColor

    init(selectedAccent: Binding<AppAccentColor>) {
        self._selectedAccent = selectedAccent
        self._localAccent = State(initialValue: selectedAccent.wrappedValue)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppAccentColor.allCases) { accent in
                let isSelected = localAccent == accent
                
                Button {
                    // 1. Instantly animate local pill
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        localAccent = accent
                    }
                    // 2. Small delay for synchronization
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        selectedAccent = accent
                    }
                } label: {
                    ZStack {
                        // The Color Circle
                        Circle()
                            .fill(accent.color)
                            .frame(width: 25, height: 25)
                        
                        // Inner checkmark
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        // Background pill
                        if isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(accent.color)
                                .matchedGeometryEffect(id: "ACCENT_TAB", in: animation)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background{
            Rectangle()
                .fill(.ultraThinMaterial)
        }
        
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .onChange(of: selectedAccent) { _, newValue in
            if localAccent != newValue {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    localAccent = newValue
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        AccentSegmentedPicker(selectedAccent: .constant(.yellow))
        AccentSegmentedPicker(selectedAccent: .constant(.purple))
    }
    .padding()
    .withAppTheme()
}
