import SwiftUI

@main
struct KeyboardAIApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if !appState.hasCompletedOnboarding {
                    OnboardingView()
                        .environmentObject(appState)
                } else if !appState.hasSeenPaywall && !AuthManager.shared.isPro {
                    ProUpgradeView(isHardPaywall: true)
                        .environmentObject(appState)
                } else {
                    MainView()
                        .environmentObject(appState)
                }
            }
            .animation(.easeInOut(duration: 0.45), value: appState.hasCompletedOnboarding)
            .animation(.easeInOut(duration: 0.45), value: appState.hasSeenPaywall)
        }
    }
}

// MARK: - App State
final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var userTier: String
    @Published var hasSeenPaywall: Bool {
        didSet {
            UserDefaults(suiteName: Configuration.appGroupIdentifier)?
                .set(hasSeenPaywall, forKey: "kbHasSeenPaywall")
        }
    }

    init() {
        let ud = UserDefaults(suiteName: Configuration.appGroupIdentifier)
        self.hasCompletedOnboarding = ud?.bool(forKey: Configuration.udKeyOnboardingCompleted) ?? false
        self.hasSeenPaywall = ud?.bool(forKey: "kbHasSeenPaywall") ?? false
        self.userTier = AuthManager.shared.getUserTier()

        Task {
            if AuthManager.shared.getToken() == nil {
                try? await AuthManager.shared.register()
            }
        }
    }

    func completeOnboarding() {
        UserDefaults(suiteName: Configuration.appGroupIdentifier)?
            .set(true, forKey: Configuration.udKeyOnboardingCompleted)
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
}
