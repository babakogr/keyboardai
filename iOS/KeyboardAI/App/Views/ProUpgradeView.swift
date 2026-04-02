import SwiftUI
import StoreKit

struct ProUpgradeView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanType = .weekly
    @State private var isPurchasing = false
    
    enum PlanType: String, CaseIterable {
        case weekly = "Weekly"
        case monthly = "Monthly"
        
        var price: String {
            switch self {
            case .weekly: return "$2.99"
            case .monthly: return "$7.99"
            }
        }
        
        var savings: String? {
            switch self {
            case .weekly: return nil
            case .monthly: return "Save 33%"
            }
        }
        
        // StoreKit product identifiers
        var productId: String {
            switch self {
            case .weekly: return "com.keyboardai.pro.weekly"
            case .monthly: return "com.keyboardai.pro.monthly"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.kbBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Hero
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.kbGradientStart, .kbGradientEnd],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 36, weight: .medium))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Upgrade to Pro")
                                .font(.kbTitle)
                                .foregroundColor(.kbLabel)
                            
                            Text("Unlock unlimited AI power")
                                .font(.kbBody)
                                .foregroundColor(.kbSecondaryLabel)
                        }
                        .padding(.top, 20)
                        
                        // Benefits
                        VStack(spacing: 14) {
                            benefitRow(icon: "infinity", text: "Unlimited AI actions", color: .kbAccent)
                            benefitRow(icon: "bolt.fill", text: "Priority processing speed", color: .orange)
                            benefitRow(icon: "globe", text: "All 14 languages", color: .blue)
                            benefitRow(icon: "sparkles", text: "Advanced rewriting", color: .purple)
                            benefitRow(icon: "bubble.left.and.bubble.right", text: "Smart reply generation", color: .green)
                        }
                        .padding(.horizontal, 4)
                        
                        // Plan selection
                        VStack(spacing: 12) {
                            ForEach(PlanType.allCases, id: \.rawValue) { plan in
                                planCard(plan: plan)
                            }
                        }
                        
                        // Purchase button
                        Button(action: { handlePurchase() }) {
                            if isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Subscribe for \(selectedPlan.price)/\(selectedPlan == .weekly ? "week" : "month")")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(isPurchasing)
                        .padding(.horizontal, 4)
                        
                        // Legal
                        VStack(spacing: 4) {
                            Text("Cancel anytime. Subscription auto-renews.")
                                .font(.system(size: 11))
                                .foregroundColor(.kbSecondaryLabel)
                            
                            HStack(spacing: 16) {
                                Button("Terms of Service") {}
                                    .font(.system(size: 11))
                                Button("Privacy Policy") {}
                                    .font(.system(size: 11))
                                Button("Restore Purchases") {
                                    // Handle restore
                                }
                                .font(.system(size: 11))
                            }
                            .foregroundColor(.kbAccent)
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.kbSecondaryLabel.opacity(0.6))
                    }
                }
            }
        }
    }
    
    // MARK: - Benefit Row
    private func benefitRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.kbLabel)
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.kbSuccess)
        }
    }
    
    // MARK: - Plan Card
    private func planCard(plan: PlanType) -> some View {
        Button(action: { selectedPlan = plan }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(plan.rawValue)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.kbLabel)
                        
                        if let savings = plan.savings {
                            Text(savings)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.kbSuccess)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(plan.price)
                        .font(.system(size: 13))
                        .foregroundColor(.kbSecondaryLabel)
                }
                
                Spacer()
                
                Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(selectedPlan == plan ? .kbAccent : .kbSeparator)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(selectedPlan == plan ? Color.kbAccent : Color.kbSeparator.opacity(0.5), lineWidth: selectedPlan == plan ? 2 : 1)
            )
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(selectedPlan == plan ? Color.kbAccentLight : Color.clear)
            )
        }
    }
    
    // MARK: - Purchase
    private func handlePurchase() {
        isPurchasing = true
        
        // In production, use StoreKit 2 to handle the actual purchase:
        // 1. Load products from App Store
        // 2. Purchase the selected product
        // 3. Verify receipt on backend
        // 4. Upgrade user tier
        
        Task {
            do {
                // Simulated purchase flow - replace with real StoreKit 2
                try await Task.sleep(nanoseconds: 2_000_000_000)
                try await AuthManager.shared.upgradeToPro(receipt: "simulated_receipt")
                
                await MainActor.run {
                    appState.userTier = "pro"
                    isPurchasing = false
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                }
            }
        }
    }
}
