import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab: Tab = .home

    enum Tab: String {
        case home, tryit, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(Tab.home)

            ChatTestView()
                .tabItem {
                    Image(systemName: "keyboard.fill")
                    Text("Try It")
                }
                .tag(Tab.tryit)

            SettingsTabView()
                .environmentObject(appState)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(Tab.settings)
        }
        .tint(.kbAccent)
    }
}

// MARK: - Home Tab
struct HomeTab: View {
    @EnvironmentObject var appState: AppState
    @State private var showProUpgrade = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    headerCard
                    if !AuthManager.shared.isPro { usageSection }
                    keyboardSetupSection
                    featuresSection
                    if !AuthManager.shared.isPro { upgradeBanner }
                    privacyNote
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("KeyboardAI")
            .sheet(isPresented: $showProUpgrade) {
                ProUpgradeView(isHardPaywall: false)
                    .environmentObject(appState)
            }
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.kbGradientStart, .kbGradientEnd],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    )
                )

            // Decorative circles
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 140, height: 140)
                .offset(x: 220, y: -40)
            Circle()
                .fill(Color.white.opacity(0.06))
                .frame(width: 100, height: 100)
                .offset(x: 260, y: 30)

            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(AuthManager.shared.isPro ? "PRO" : "FREE")
                        .font(.system(size: 11, weight: .heavy))
                        .tracking(1)
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())

                    Text("AI Typing at\nYour Fingertips")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineSpacing(2)

                    if !AuthManager.shared.isPro {
                        Text("\(UsageTracker.shared.remainingFreeUses) actions left today")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                Spacer()
            }
            .padding(22)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    // MARK: - Usage Section
    private var usageSection: some View {
        VStack(spacing: 12) {
            HStack {
                Label("Today's Usage", systemImage: "chart.bar.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.kbLabel)
                Spacer()
                Text("\(UsageTracker.shared.dailyUsageCount)/\(Configuration.freeDailyLimit)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.kbAccent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemFill)).frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(colors: [.kbGradientStart, .kbGradientEnd], startPoint: .leading, endPoint: .trailing))
                        .frame(width: max(8, geo.size.width * CGFloat(UsageTracker.shared.dailyUsageCount) / CGFloat(max(1, Configuration.freeDailyLimit))), height: 8)
                }
            }
            .frame(height: 8)

            Text("\(UsageTracker.shared.remainingFreeUses) AI actions remaining · Resets at midnight")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Keyboard Setup Section
    private var keyboardSetupSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "keyboard.badge.ellipsis")
                    .font(.system(size: 22))
                    .foregroundColor(.kbAccent)
                    .frame(width: 40, height: 40)
                    .background(Color.kbAccent.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Keyboard Setup")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.kbLabel)
                    Text("Add KeyboardAI to your keyboards")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
            }

            VStack(spacing: 8) {
                nativeStep("1", "Open", "Settings → General → Keyboard → Keyboards")
                nativeStep("2", "Tap", "Add New Keyboard → Select KeyboardAI")
                nativeStep("3", "Enable", "Allow Full Access → Tap Allow")
            }

            Button(action: openKeyboardSettings) {
                Label("Open Keyboard Settings", systemImage: "arrow.up.right")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.kbAccent)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func nativeStep(_ n: String, _ bold: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Text(n)
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(Color.kbAccent)
                .clipShape(Circle())
            Group {
                Text(bold).fontWeight(.semibold) + Text("  \(text)")
            }
            .font(.system(size: 13))
            .foregroundColor(.secondary)
            Spacer()
        }
    }

    private func openKeyboardSettings() {
        if let url = URL(string: "App-prefs:General&path=Keyboard") {
            UIApplication.shared.open(url)
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Features Section
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Features")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.kbLabel)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                featureCell("globe", "Translate", "14 languages", .blue)
                featureCell("wand.and.stars", "Improve", "Rewrite text", .purple)
                featureCell("checkmark.circle.fill", "Fix Grammar", "Auto-correct", .green)
                featureCell("bubble.left.and.bubble.right.fill", "Smart Reply", "AI responses", .orange)
            }
        }
    }

    private func featureCell(_ icon: String, _ title: String, _ desc: String, _ color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(color.gradient)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.kbLabel)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    // MARK: - Upgrade Banner
    private var upgradeBanner: some View {
        Button(action: { showProUpgrade = true }) {
            HStack(spacing: 14) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.yellow.gradient)
                    .frame(width: 44, height: 44)
                    .background(Color.yellow.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text("Upgrade to Pro")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("Unlimited · All languages · Priority speed")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.4, green: 0.25, blue: 0.9), Color(red: 0.65, green: 0.2, blue: 0.85)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    // MARK: - Privacy Note
    private var privacyNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 16))
                .foregroundStyle(Color.green.gradient)
            Text("Your text is never stored. AI processes only when you tap.")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Settings Tab Wrapper
struct SettingsTabView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        SettingsView()
            .environmentObject(appState)
    }
}
