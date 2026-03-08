import SwiftUI

struct SettingsView: View {
    @AppStorage("app_theme") private var selectedTheme: AppTheme = .system
    @AppStorage("app_accent") private var selectedAccent: AppAccentColor = .yellow
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: – Appearance
                Section("Appearance") {
                    ThemeSegmentedPicker(
                        selectedTheme: $selectedTheme,
                        accentColor: selectedAccent.color
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .listRowBackground(Color.clear)
                }

                // MARK: – Accent Color
                Section("Accent Color") {
                    AccentSegmentedPicker(selectedAccent: $selectedAccent)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                }

                // MARK: – About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbarTitleDisplayMode(.inlineLarge)
        }
        .withAppTheme()
    }
}

struct ThemeSegmentedPicker: View {
    @Binding var selectedTheme: AppTheme
    let accentColor: Color
    @Namespace private var animation
    @State private var localTheme: AppTheme

    init(selectedTheme: Binding<AppTheme>, accentColor: Color) {
        self._selectedTheme = selectedTheme
        self.accentColor = accentColor
        self._localTheme = State(initialValue: selectedTheme.wrappedValue)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTheme.allCases) { theme in
                let isSelected = localTheme == theme
                
                Button {
                    // 1. Instantly animate the local pill slider
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                        localTheme = theme
                    }
                    // 2. Slightly delay the global AppStorage update.
                    // This prevents the TabView from applying an overarching global
                    // fade animation that interrupts our targeted matched geometry spring.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        selectedTheme = theme
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: theme.symbol)
                            .font(.title2)
                        Text(theme.rawValue)
                            .font(.caption)
                            .fontWidth(.expanded)
                            .fontWeight(isSelected ? .semibold : .medium)
                    }
                    .foregroundColor(isSelected ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background {
                        if isSelected {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(accentColor.opacity(1))
                                .glassEffect(.clear,in:.rect(cornerRadius: 18))
                                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                                .matchedGeometryEffect(id: "THEME_TAB", in: animation)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color(uiColor: .tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onChange(of: selectedTheme) { _, newValue in
            // Keep local state in sync if AppStorage changes externally
            if localTheme != newValue {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                    localTheme = newValue
                }
            }
        }
    }
}

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
                    // 2. Small delay for AppStorage state
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        selectedAccent = accent
                    }
                } label: {
                    ZStack {
                        // The Color Circle
                        Circle()
                            .fill(accent.color)
                            .frame(width: 28, height: 28)
                        
                        // Inner checkmark
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        // Background pill
                        if isSelected {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(accent.color)
                                .shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)
                                .matchedGeometryEffect(id: "ACCENT_TAB", in: animation)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color(uiColor: .tertiarySystemFill))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onChange(of: selectedAccent) { _, newValue in
            // Stay in sync if selectedAccent changes globally (e.g by resetting)
            if localAccent != newValue {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    localAccent = newValue
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .withAppTheme()
}
