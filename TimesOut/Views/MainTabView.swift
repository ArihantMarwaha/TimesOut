import SwiftUI
import SwiftData

enum Tab: String {
    case tasks
    case routine
    case archive
    case settings
}

struct MainTabView: View {
    @AppStorage("selected_tab") private var selectedTab: Tab = .tasks
    @State private var viewModel = TaskDashboardViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarMainView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "calendar")
                }
                .tag(Tab.tasks)
            
            RoutineView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "sparkles")
                }
                .tag(Tab.routine)
            
            ArchiveView()
                .tabItem {
                    Image(systemName: "archivebox.fill")
                }
                .tag(Tab.archive)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                }
                .tag(Tab.settings)
        }
        .withAppTheme()
    }
}

#Preview {
    MainTabView()
        .withAppTheme()
        .modelContainer(previewContainer)
}
