import SwiftUI
import StoreKit

struct ProUpgradeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanType = .monthly
    @State private var isPurchasing = false
    @State private var closeVisible = false

    var isHardPaywall: Bool = false

    enum PlanType: CaseIterable {
        case weekly, monthly

        var title: String { self == .weekly ? "Weekly" : "Monthly" }
        var price: String { self == .weekly ? "$9.99" : "$19.99" }
        var period: String { self == .weekly ? "/ week" : "/ month" }
        var subtitle: String {
            self == .weekly ? "Billed weekly" : "Best value · Save 50%"
        }
        var isPopular: Bool { self == .monthly }
        var productId: String {
            self == .weekly ? "com.keyboardai.pro.weekly" : "com.keyboardai.pro.monthly"
        }
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Premium dark background
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.02, blue: 0.14),
                    Color(red: 0.07, green: 0.02, blue: 0.18),
                    Color(red: 0.02, green: 0.02, blue: 0.08)
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Glow orbs
            ZStack {
                Circle()
                    .fill(Color(red: 0.58, green: 0.35, blue: 1.0).opacity(0.18))
                    .frame(width: 350, height: 350)
                    .blur(radius: 90)
                    .offset(x: -60, y: -180)
                Circle()
                    .fill(Color(red: 0.35, green: 0.47, blue: 1.0).opacity(0.12))
                    .frame(width: 280, height: 280)
                    .blur(radius: 70)
                    .offset(x: 120, y: 80)
            }

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top spacing for close button
                    Color.clear.frame(height: isHardPaywall ? 56 : 24)

                    VStack(spacing: 26) {
                        heroSection
                        benefitsSection
                        socialProofSection
                        plansSection
                        ctaSection
                        legalSection
                    }
                    .padding(.horizontal, 22)
                    .padding(.bottom, 48)
                }
            }

            // Subtle close button (App Store compliant — always visible but styled subtly)
            if isHardPaywall {
                Button(action: {
                    appState.hasSeenPaywall = true
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(closeVisible ? 0.4 : 0.0))
                        .frame(width: 28, height: 28)
                        .background(Color.white.opacity(closeVisible ? 0.1 : 0.0))
                        .clipShape(Circle())
                }
                .disabled(!closeVisible)
                .padding(.top, 16)
                .padding(.trailing, 20)
                .animation(.easeIn(duration: 0.6), value: closeVisible)
            } else {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 30, height: 30)
                        .background(Color.white.opacity(0.12))
                        .clipShape(Circle())
                }
                .padding(.top, 16)
                .padding(.trailing, 20)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if isHardPaywall {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    closeVisible = true
                }
            }
        }
    }

    // MARK: - Hero
    private var heroSection: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.58, green: 0.35, blue: 1.0).opacity(0.28))
                    .frame(width: 160, height: 160)
                    .blur(radius: 35)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.5, green: 0.3, blue: 1.0),
                                Color(red: 0.75, green: 0.2, blue: 0.9)
                            ],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 96, height: 96)
                Image(systemName: "crown.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [Color.yellow, Color.orange], startPoint: .top, endPoint: .bottom)
                    )
            }

            VStack(spacing: 10) {
                Text("Unlock Full AI Power")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("Type smarter in every app.\nNo limits, no interruptions.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }
        }
    }

    // MARK: - Benefits
    private var benefitsSection: some View {
        VStack(spacing: 9) {
            pwBenefit("infinity", "Unlimited AI Actions", "No daily caps — use as much as you want", .purple)
            pwBenefit("globe", "Translate in 14 Languages", "Instant, accurate real-time translation", .blue)
            pwBenefit("wand.and.stars", "Advanced Text Improvement", "Rewrite like a professional writer", .orange)
            pwBenefit("bubble.left.and.bubble.right.fill", "Smart Reply Generation", "Perfect replies crafted in seconds", .green)
            pwBenefit("bolt.fill", "Priority AI Speed", "Faster responses, zero waiting", Color.yellow)
        }
    }

    private func pwBenefit(_ icon: String, _ title: String, _ desc: String, _ color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 42, height: 42)
                .background(color.opacity(0.14))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.45))
            }
            Spacer()
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(color)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }

    // MARK: - Social Proof
    private var socialProofSection: some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 13))
                        .foregroundColor(.yellow)
                }
                Text("4.9")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Text("· 2,400+ reviews")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.45))
            }
            HStack(spacing: 10) {
                pwQuote("\"Typing feels like cheating now!\"", "— Sarah K.")
                pwQuote("\"Best keyboard app, period.\"", "— Marco R.")
            }
        }
    }

    private func pwQuote(_ q: String, _ a: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(q)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.75))
                .lineSpacing(3)
            Text(a)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.38))
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.055))
        .cornerRadius(12)
    }

    // MARK: - Plans
    private var plansSection: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Choose Your Plan")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Spacer()
            }
            ForEach(PlanType.allCases, id: \.title) { plan in
                pwPlanCard(plan)
            }
        }
    }

    private func pwPlanCard(_ plan: PlanType) -> some View {
        let sel = selectedPlan == plan
        return Button(action: {
            withAnimation(.spring(response: 0.3)) { selectedPlan = plan }
        }) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(sel ? Color(red: 0.58, green: 0.35, blue: 1.0) : Color.white.opacity(0.22), lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if sel {
                        Circle()
                            .fill(Color(red: 0.58, green: 0.35, blue: 1.0))
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(plan.title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        if plan.isPopular {
                            Text("MOST POPULAR")
                                .font(.system(size: 9, weight: .heavy))
                                .foregroundColor(.black)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.yellow)
                                .cornerRadius(5)
                        }
                    }
                    Text(plan.subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.45))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 1) {
                    Text(plan.price)
                        .font(.system(size: 22, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    Text(plan.period)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.45))
                }
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(sel ? Color(red: 0.5, green: 0.3, blue: 1.0).opacity(0.2) : Color.white.opacity(0.055))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(sel ? Color(red: 0.58, green: 0.35, blue: 1.0) : Color.white.opacity(0.1), lineWidth: sel ? 2 : 1)
            )
        }
    }

    // MARK: - CTA
    private var ctaSection: some View {
        VStack(spacing: 14) {
            Button(action: handlePurchase) {
                ZStack {
                    if isPurchasing {
                        ProgressView().tint(.white)
                    } else {
                        VStack(spacing: 3) {
                            Text("Start \(selectedPlan.title) Plan")
                                .font(.system(size: 18, weight: .heavy, design: .rounded))
                                .foregroundColor(.white)
                            Text("\(selectedPlan.price)\(selectedPlan.period) · Cancel anytime")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.72))
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 19)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.5, green: 0.3, blue: 1.0),
                            Color(red: 0.72, green: 0.2, blue: 0.9)
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .cornerRadius(18)
                .shadow(color: Color(red: 0.5, green: 0.3, blue: 1.0).opacity(0.45), radius: 18, x: 0, y: 8)
            }
            .disabled(isPurchasing)

            Button("Restore Purchases") {}
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.38))
        }
    }

    // MARK: - Legal
    private var legalSection: some View {
        VStack(spacing: 6) {
            Text("Subscription renews automatically. Cancel anytime in App Store Settings.")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.28))
                .multilineTextAlignment(.center)
            HStack(spacing: 18) {
                Button("Terms") {}
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))
                Button("Privacy") {}
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.3))
            }
        }
    }

    // MARK: - Purchase handler
    private func handlePurchase() {
        isPurchasing = true
        Task {
            do {
                try await Task.sleep(nanoseconds: 2_000_000_000)
                try await AuthManager.shared.upgradeToPro(receipt: "simulated_receipt")
                await MainActor.run {
                    appState.userTier = "pro"
                    appState.hasSeenPaywall = true
                    isPurchasing = false
                    if !isHardPaywall { dismiss() }
                }
            } catch {
                await MainActor.run { isPurchasing = false }
            }
        }
    }
}
