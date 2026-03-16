import SwiftUI

struct RoutineDetailsSection: View {
    @Binding var title: String
    
    var body: some View {
        Section {
            TextField("Routine Title", text: $title)
                .font(.system(size: 18, weight: .semibold, design: .monospaced))
        } header: {
            Text("Routine Details")
                .fontWeight(.semibold)
                .fontWidth(.expanded)
        }
    }
}

#Preview {
    Form {
        RoutineDetailsSection(title: .constant("Morning Routine"))
    }
    .withAppTheme()
}
