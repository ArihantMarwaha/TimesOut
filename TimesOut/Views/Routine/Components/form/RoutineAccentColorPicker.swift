import SwiftUI

struct RoutineAccentColorPicker: View {
    @Binding var accentColor: String
    
    var body: some View {
        Section {
            AccentSegmentedPicker(selectedAccent: Binding(
                get: { AppAccentColor(rawValue: accentColor) ?? .yellow },
                set: { accentColor = $0.rawValue }
            ))
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .listRowBackground(Color.clear)
            .padding(.vertical, 8)
        } header: {
            Text("Accent Color")
                .fontWeight(.semibold)
                .fontWidth(.expanded)
        }
    }
}

#Preview {
    Form {
        RoutineAccentColorPicker(accentColor: .constant("yellow"))
    }
    .withAppTheme()
}
