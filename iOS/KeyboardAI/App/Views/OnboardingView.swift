import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    
    private let pages: [(icon: String, title: String, subtitle: String, color: Color)] = [
        ("keyboard", "AI Keyboard", "Type smarter with AI-powered assistance right from your keyboard.", .kbAccent),
        ("sparkles", "One Tap Magic", "Translate, improve, fix grammar, or generate replies — all with a single tap.", .kbGradientEnd),
        ("bolt.shield", "Private & Secure", "Your text is never stored. AI processes only when you tap a button.", .kbSuccess),
        ("gear", "Enable Keyboard", "Follow the steps below to activate your AI Keyboard.", .kbWarning)
    ]
    
    var body: some View {
        ZStack {
            Color.kbBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        VStack(spacing: 24) {
                            Spacer()
                            
                            // Icon
                            ZStack {
                                Circle()
                                    .fill(pages[index].color.opacity(0.12))
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: pages[index].icon)
                                    .font(.system(size: 48, weight: .medium))
                                    .foregroundColor(pages[index].color)
                            }
                            
                            // Title
                            Text(pages[index].title)
                                .font(.kbTitle)
                                .foregroundColor(.kbLabel)
                            
                            // Subtitle
                            Text(pages[index].subtitle)
                                .font(.kbBody)
                                .foregroundColor(.kbSecondaryLabel)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            // Setup instructions on last page
                            if index == pages.count - 1 {
                                setupInstructions
                            }
                            
                            Spacer()
                        }
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)
                
                // Bottom section
                VStack(spacing: 20) {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule()
                                .fill(index == currentPage ? Color.kbAccent : Color.kbSeparator)
                                .frame(width: index == currentPage ? 24 : 8, height: 8)
                                .animation(.easeInOut(duration: 0.3), value: currentPage)
                        }
                    }
                    
                    // Button
                    Button(action: {
                        if currentPage < pages.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            appState.completeOnboarding()
                        }
                    }) {
                        Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 24)
                    
                    // Skip button
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            appState.completeOnboarding()
                        }
                        .font(.kbBody)
                        .foregroundColor(.kbSecondaryLabel)
                    }
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Setup Instructions
    private var setupInstructions: some View {
        VStack(alignment: .leading, spacing: 12) {
            setupStep(number: "1", text: "Open Settings → General → Keyboard")
            setupStep(number: "2", text: "Tap \"Keyboards\" → \"Add New Keyboard\"")
            setupStep(number: "3", text: "Select \"KeyboardAI\"")
            setupStep(number: "4", text: "Enable \"Allow Full Access\"")
        }
        .padding(20)
        .background(Color.kbSecondaryBg)
        .cornerRadius(16)
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
    
    private func setupStep(number: String, text: String) -> some View {
        HStack(spacing: 12) {
            Text(number)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(Color.kbAccent)
                .clipShape(Circle())
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.kbLabel)
            
            Spacer()
        }
    }
}
