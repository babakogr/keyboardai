import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage: String
    
    init() {
        let defaults = UserDefaults(suiteName: Configuration.appGroupIdentifier)
        _selectedLanguage = State(initialValue: defaults?.string(forKey: Configuration.udKeySelectedLanguage) ?? "EN")
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Account section
                Section {
                    HStack {
                        Label("Plan", systemImage: "person.crop.circle")
                        Spacer()
                        Text(AuthManager.shared.isPro ? "Pro ✨" : "Free")
                            .foregroundColor(.kbSecondaryLabel)
                    }
                    
                    if !AuthManager.shared.isPro {
                        HStack {
                            Label("Daily Uses", systemImage: "chart.bar")
                            Spacer()
                            Text("\(UsageTracker.shared.dailyUsageCount)/\(Configuration.freeDailyLimit)")
                                .foregroundColor(.kbSecondaryLabel)
                        }
                    }
                } header: {
                    Text("Account")
                }
                
                // Language section
                Section {
                    Picker(selection: $selectedLanguage) {
                        ForEach(Configuration.supportedLanguages, id: \.code) { lang in
                            Text("\(lang.flag) \(lang.name)")
                                .tag(lang.code)
                        }
                    } label: {
                        Label("Default Language", systemImage: "globe")
                    }
                    .onChange(of: selectedLanguage) { _, newValue in
                        let defaults = UserDefaults(suiteName: Configuration.appGroupIdentifier)
                        defaults?.set(newValue, forKey: Configuration.udKeySelectedLanguage)
                    }
                } header: {
                    Text("Language")
                }
                
                // Keyboard section
                Section {
                    Button(action: {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label("Keyboard Settings", systemImage: "keyboard")
                    }
                } header: {
                    Text("Keyboard")
                } footer: {
                    Text("Enable KeyboardAI in Settings → General → Keyboard → Keyboards")
                }
                
                // Privacy section
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                            .font(.system(size: 15, weight: .medium))
                        
                        Text("• Text is sent to AI only when you tap an action button\n• No text is permanently stored on our servers\n• Responses are cached temporarily for performance\n• We do not sell or share your data\n• All communication is encrypted via HTTPS")
                            .font(.system(size: 13))
                            .foregroundColor(.kbSecondaryLabel)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Privacy & Security")
                }
                
                // About section
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.kbSecondaryLabel)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
