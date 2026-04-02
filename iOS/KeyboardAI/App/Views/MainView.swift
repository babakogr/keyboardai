import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .environmentObject(appState)
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            ChatTestView()
                .tabItem {
                    Label("Try It", systemImage: selectedTab == 1 ? "keyboard.fill" : "keyboard")
                }
                .tag(1)

            SettingsTabView()
                .environmentObject(appState)
                .tabItem {
                    Label("Settings", systemImage: selectedTab == 2 ? "gearshape.fill" : "gearshape")
                }
                .tag(2)
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
            ZStack {
                Color.kbBackground.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        headerCard
                        if !AuthManager.shared.isPro { usageCard }
                        keyboardSetupCard
                        featuresGrid
                        if !AuthManager.shared.isPro { upgradeBanner }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(LinearGradient(colors: [.kbGradientStart, .kbGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 28, height: 28)
                            Image(systemName: "keyboard.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        Text("KeyboardAI")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.kbLabel)
                    }
                }
            }
            .sheet(isPresented: $showProUpgrade) {
                ProUpgradeView(isHardPaywall: false)
                    .environmentObject(appState)
            }
        }
    }

    // MARK: - Header Card
    private var headerCard: some View {
        ZStack {
            LinearGradient(
                colors: [.kbGradientStart, .kbGradientEnd],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .cornerRadius(20)

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(AuthManager.shared.isPro ? "Pro Member ✨" : "Free Plan")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)

                    Text("AI typing at\nyour fingertips")
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .lineSpacing(3)

                    if !AuthManager.shared.isPro {
                        Text("\(UsageTracker.shared.remainingFreeUses) uses left today")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.75))
                    }
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 72, height: 72)
                    Image(systemName: "sparkles")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(22)
        }
        .frame(height: 150)
    }

    // MARK: - Usage Card
    private var usageCard: some View {
        VStack(spacing: 14) {
            HStack {
                Text("Today's Usage")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.kbLabel)
                Spacer()
                Text("\(UsageTracker.shared.dailyUsageCount) / \(Configuration.freeDailyLimit)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.kbAccent)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.kbSeparator.opacity(0.25)).frame(height: 8)
                    Capsule()
                        .fill(LinearGradient(colors: [.kbGradientStart, .kbGradientEnd], startPoint: .leading, endPoint: .trailing))
                        .frame(
                            width: max(8, geo.size.width * CGFloat(UsageTracker.shared.dailyUsageCount) / CGFloat(max(1, Configuration.freeDailyLimit))),
                            height: 8
                        )
                }
            }
            .frame(height: 8)

            HStack {
                Text("\(UsageTracker.shared.remainingFreeUses) AI actions remaining")
                    .font(.system(size: 12))
                    .foregroundColor(.kbSecondaryLabel)
                Spacer()
                Text("Resets at midnight")
                    .font(.system(size: 11))
                    .foregroundColor(.kbSecondaryLabel.opacity(0.6))
            }
        }
        .cardStyle()
    }

    // MARK: - Keyboard Setup Card
    private var keyboardSetupCard: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.kbAccentLight)
                        .frame(width: 40, height: 40)
                    Image(systemName: "keyboard.badge.ellipsis.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.kbAccent)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Keyboard Setup")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.kbLabel)
                    Text("Enable KeyboardAI on your iPhone")
                        .font(.system(size: 12))
                        .foregroundColor(.kbSecondaryLabel)
                }
                Spacer()
            }

            VStack(spacing: 6) {
                setupStep("1", "Settings → General → Keyboard → Keyboards")
                setupStep("2", "Add New Keyboard → Select KeyboardAI")
                setupStep("3", "Enable Allow Full Access")
            }

            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.right.square.fill")
                        .font(.system(size: 15))
                    Text("Open iPhone Settings")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(
                    LinearGradient(colors: [.kbGradientStart, .kbGradientEnd], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(12)
            }
        }
        .cardStyle()
    }

    private func setupStep(_ n: String, _ text: String) -> some View {
        HStack(spacing: 10) {
            Text(n)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.kbAccent)
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.kbSecondaryLabel)
            Spacer()
        }
    }

    // MARK: - Features Grid
    private var featuresGrid: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Features")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.kbLabel)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                featureCell("globe", "Translate", "14 languages", .blue)
                featureCell("wand.and.stars", "Improve", "Rewrite instantly", .purple)
                featureCell("checkmark.circle.fill", "Fix Grammar", "Perfect writing", .green)
                featureCell("bubble.left.and.bubble.right.fill", "Smart Reply", "3 options fast", .orange)
            }
        }
    }

    private func featureCell(_ icon: String, _ title: String, _ desc: String, _ color: Color) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(color)
            }
            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.kbLabel)
                Text(desc)
                    .font(.system(size: 11))
                    .foregroundColor(.kbSecondaryLabel)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(Color.kbSecondaryBg)
        .cornerRadius(16)
    }

    // MARK: - Upgrade Banner
    private var upgradeBanner: some View {
        Button(action: { showProUpgrade = true }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle().fill(Color.yellow.opacity(0.2)).frame(width: 44, height: 44)
                    Image(systemName: "crown.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.yellow)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("Upgrade to Pro")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("Unlimited · All languages · Priority speed")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.75))
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(18)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.4, green: 0.25, blue: 0.9), Color(red: 0.65, green: 0.2, blue: 0.85)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
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
