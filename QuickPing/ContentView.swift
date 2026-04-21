import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            ContactsListView()
                .tabItem {
                    Label("Contacts", systemImage: "person.2.fill")
                }
                .tag(1)

            TemplatesListView()
                .tabItem {
                    Label("Templates", systemImage: "doc.text.fill")
                }
                .tag(2)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
    }
}
