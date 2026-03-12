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
    
    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarMainView()
                .tabItem {
                    Image(systemName: "calendar")
                }
                .tag(Tab.tasks)
            
            RoutineView()
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
