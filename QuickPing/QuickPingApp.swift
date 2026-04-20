import SwiftUI

@main
struct QuickPingApp: App {
    @StateObject private var dataStore = DataStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataStore)
        }
    }
}
