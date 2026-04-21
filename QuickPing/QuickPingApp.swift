import SwiftUI

@main
struct QuickPingApp: App {
    @StateObject private var dataStore = DataStore.shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView()
                    .environmentObject(dataStore)
            } else {
                OnboardingView()
            }
        }
    }
}
