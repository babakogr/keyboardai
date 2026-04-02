import SwiftUI

struct MainView: View {
    @EnvironmentObject var appState: AppState
    @State private var showSettings = false
    @State private var showProUpgrade = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.kbBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Usage card
                        usageCard
                        
                        // Features preview
                        featuresSection
                        
                        // Keyboard setup status
                        keyboardStatusCard
                        
                        // Pro upgrade banner (for free users)
                        if !AuthManager.shared.isPro {
                            proUpgradeBanner
                        }
                        
                        // Privacy note
                        privacyNote
                    }
                    .padding(20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(.kbSecondaryLabel)
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showProUpgrade) {
                ProUpgradeView()
                    .environmentObject(appState)
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("KeyboardAI")
                        .font(.kbTitle)
                        .foregroundColor(.kbLabel)
                    
                    Text(AuthManager.shared.isPro ? "Pro Member ✨" : "Free Plan")
                        .font(.kbCaption)
                        .foregroundColor(AuthManager.shared.isPro ? .kbAccent : .kbSecondaryLabel)
                }
                Spacer()
                
                // App icon placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [.kbGradientStart, .kbGradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "keyboard")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Usage Card
    private var usageCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Usage")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.kbLabel)
                Spacer()
                
                if AuthManager.shared.isPro {
                    Text("Unlimited")
                        .font(.kbChip)
                        .foregroundColor(.kbAccent)
                } else {
                    Text("\(UsageTracker.shared.dailyUsageCount)/\(Configuration.freeDailyLimit)")
                        .font(.kbChip)
                        .foregroundColor(.kbSecondaryLabel)
                }
            }
            
            if !AuthManager.shared.isPro {
                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.kbSeparator.opacity(0.3))
                            .frame(height: 6)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.kbGradientStart, .kbGradientEnd],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geo.size.width * CGFloat(UsageTracker.shared.dailyUsageCount) / CGFloat(Configuration.freeDailyLimit),
                                height: 6
                            )
                    }
                }
                .frame(height: 6)
                
                Text("\(UsageTracker.shared.remainingFreeUses) AI actions remaining today")
                    .font(.kbCaption)
                    .foregroundColor(.kbSecondaryLabel)
            }
        }
        .cardStyle()
    }
    
    // MARK: - Features
    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Features")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.kbLabel)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                featureCard(icon: "globe", title: "Translate", desc: "14 languages", color: .blue)
                featureCard(icon: "sparkles", title: "Improve", desc: "Rewrite text", color: .purple)
                featureCard(icon: "checkmark.circle", title: "Fix", desc: "Grammar check", color: .green)
                featureCard(icon: "bubble.left.and.bubble.right", title: "Reply", desc: "Smart replies", color: .orange)
            }
        }
    }
    
    private func featureCard(icon: String, title: String, desc: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.kbLabel)
            
            Text(desc)
                .font(.system(size: 12))
                .foregroundColor(.kbSecondaryLabel)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(color.opacity(0.08))
        .cornerRadius(14)
    }
    
    // MARK: - Keyboard Status
    private var keyboardStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "keyboard")
                    .font(.system(size: 20))
                    .foregroundColor(.kbAccent)
                
                Text("Keyboard Setup")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.kbLabel)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.kbSecondaryLabel)
            }
            
            Text("Go to Settings → General → Keyboard → Keyboards → Add New Keyboard → KeyboardAI")
                .font(.system(size: 13))
                .foregroundColor(.kbSecondaryLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Button(action: {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Open Settings")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.kbAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color.kbAccentLight)
                    .cornerRadius(10)
            }
        }
        .cardStyle()
    }
    
    // MARK: - Pro Upgrade Banner
    private var proUpgradeBanner: some View {
        Button(action: { showProUpgrade = true }) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Upgrade to Pro")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("Unlimited AI actions, all features")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [.kbGradientStart, .kbGradientEnd],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
    }
    
    // MARK: - Privacy Note
    private var privacyNote: some View {
        HStack(spacing: 10) {
            Image(systemName: "lock.shield")
                .font(.system(size: 16))
                .foregroundColor(.kbSuccess)
            
            Text("Your text is never stored. AI processes only when you tap a button.")
                .font(.system(size: 13))
                .foregroundColor(.kbSecondaryLabel)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.kbSuccess.opacity(0.08))
        .cornerRadius(12)
    }
}
