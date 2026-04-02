import SwiftUI

@main
struct KeyboardAIApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            if appState.hasCompletedOnboarding {
                MainView()
                    .environmentObject(appState)
            } else {
                OnboardingView()
                    .environmentObject(appState)
            }
        }
    }
}

// MARK: - App State
final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool
    @Published var userTier: String
    @Published var isKeyboardEnabled: Bool = false
    
    init() {
        let defaults = UserDefaults(suiteName: Configuration.appGroupIdentifier)
        self.hasCompletedOnboarding = defaults?.bool(forKey: Configuration.udKeyOnboardingCompleted) ?? false
        self.userTier = AuthManager.shared.getUserTier()
        
        // Register device on first launch
        Task {
            if AuthManager.shared.getToken() == nil {
                try? await AuthManager.shared.register()
            }
        }
    }
    
    func completeOnboarding() {
        let defaults = UserDefaults(suiteName: Configuration.appGroupIdentifier)
        defaults?.set(true, forKey: Configuration.udKeyOnboardingCompleted)
        withAnimation(.easeInOut(duration: 0.5)) {
            hasCompletedOnboarding = true
        }
    }
}
