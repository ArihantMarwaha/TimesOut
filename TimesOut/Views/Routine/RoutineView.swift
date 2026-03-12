import SwiftUI

struct RoutineView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    DailyRoutineButton {
                        // Action to create routine
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                }
            }
            .navigationTitle("Routine")
        }
    }
}

#Preview {
    RoutineView()
        .withAppTheme()
}
