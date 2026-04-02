import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPage = 0
    @State private var hasOpenedSettings = false
    @State private var showContinueButton = false

    private let totalPages = 5

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress indicators
                HStack(spacing: 6) {
                    ForEach(0..<totalPages, id: \.self) { i in
                        Capsule()
                            .fill(i <= currentPage ? Color.white : Color.white.opacity(0.2))
                            .frame(width: i == currentPage ? 22 : 6, height: 6)
                            .animation(.spring(response: 0.4), value: currentPage)
                    }
                }
                .padding(.top, 56)
                .padding(.horizontal, 28)

                // Pages
                TabView(selection: $currentPage) {
                    page0.tag(0)
                    page1.tag(1)
                    page2.tag(2)
                    page3.tag(3)
                    page4.tag(4)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Bottom controls
                VStack(spacing: 14) {
                    if currentPage == totalPages - 1 {
                        // Open Settings button
                        Button(action: openSettings) {
                            HStack(spacing: 10) {
                                Image(systemName: "gear.circle.fill")
                                    .font(.system(size: 18))
                                Text("Open iPhone Settings")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 1.0, green: 0.6, blue: 0.0), Color(red: 1.0, green: 0.4, blue: 0.0)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.orange.opacity(0.5), radius: 12, x: 0, y: 6)
                        }

                        if showContinueButton {
                            Button(action: { appState.completeOnboarding() }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 17))
                                    Text("I've Enabled It — Let's Go!")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(Color.white.opacity(0.12))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                    } else {
                        Button(action: {
                            withAnimation(.spring(response: 0.4)) { currentPage += 1 }
                        }) {
                            Text(currentPage == 0 ? "Get Started" : "Continue")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 17)
                                .background(Color.white)
                                .cornerRadius(16)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .animation(.spring(response: 0.4), value: showContinueButton)
            }
        }
        .preferredColorScheme(.dark)
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
        withAnimation(.spring(response: 0.5).delay(0.3)) {
            showContinueButton = true
        }
    }

    // MARK: - Page 0: Welcome
    private var page0: some View {
        VStack(spacing: 32) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(red: 0.35, green: 0.47, blue: 1.0).opacity(0.25))
                    .frame(width: 220, height: 220)
                    .blur(radius: 50)
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.35, green: 0.47, blue: 1.0), Color(red: 0.58, green: 0.35, blue: 1.0)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                Image(systemName: "keyboard.fill")
                    .font(.system(size: 52, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: 14) {
                Text("Meet KeyboardAI")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("The world's smartest keyboard.\nTranslate, improve, fix grammar\nand craft perfect replies — instantly.")
                    .font(.system(size: 17))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }
            .padding(.horizontal, 32)

            HStack(spacing: 5) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill").font(.system(size: 13)).foregroundColor(.yellow)
                }
                Text("4.9 · Trusted by 50,000+ users")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
            }

            Spacer()
            Spacer()
        }
    }

    // MARK: - Page 1: Translate
    private var page1: some View {
        VStack(spacing: 26) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                Circle()
                    .fill(LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                Image(systemName: "globe")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: 12) {
                Text("Translate Instantly")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("Break language barriers in real-time.\n14 languages, zero effort.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 0) {
                HStack {
                    Text("🇬🇧 English")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.top, 14)
                Text("\"I'll see you at the meeting tomorrow\"")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 16).padding(.vertical, 8)
                Divider().background(Color.white.opacity(0.1))
                HStack {
                    Text("🇹🇷 Turkish")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.cyan)
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.system(size: 12)).foregroundColor(.cyan)
                }
                .padding(.horizontal, 16).padding(.top, 10)
                Text("\"Yarınki toplantıda görüşürüz\"")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.bottom, 14).padding(.top, 4)
            }
            .background(Color.white.opacity(0.07))
            .cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.1), lineWidth: 1))
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Page 2: AI Writing
    private var page2: some View {
        VStack(spacing: 26) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                Circle()
                    .fill(LinearGradient(colors: [Color.purple, Color(red: 0.8, green: 0.3, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: 12) {
                Text("AI Writing Power")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("One tap to improve, fix grammar,\nor generate perfect smart replies.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    ob2Chip("wand.and.stars", "Improve Text", Color.purple)
                    ob2Chip("checkmark.circle.fill", "Fix Grammar", Color.green)
                }
                HStack(spacing: 10) {
                    ob2Chip("bubble.left.and.bubble.right.fill", "Smart Replies", Color.orange)
                    ob2Chip("arrow.triangle.2.circlepath", "Rewrite", Color.blue)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    private func ob2Chip(_ icon: String, _ label: String, _ color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(color.opacity(0.1))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.2), lineWidth: 1))
    }

    // MARK: - Page 3: Privacy
    private var page3: some View {
        VStack(spacing: 26) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 200, height: 200)
                    .blur(radius: 50)
                Circle()
                    .fill(LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 100, height: 100)
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: 12) {
                Text("Your Privacy First")
                    .font(.system(size: 32, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                Text("We never store your messages.\nAI runs only when you tap — never passively.")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.65))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 10) {
                ob3Card("eye.slash.fill", "Zero Data Storage", "Messages are never saved or logged", .green)
                ob3Card("bolt.fill", "On-Demand Only", "AI processes only when you tap a button", .blue)
                ob3Card("lock.fill", "Encrypted Transit", "All requests secured with HTTPS", .purple)
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
    }

    private func ob3Card(_ icon: String, _ title: String, _ desc: String, _ color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.15))
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Text(desc).font(.system(size: 12)).foregroundColor(.white.opacity(0.5))
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16)).foregroundColor(color)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Color.white.opacity(0.06))
        .cornerRadius(14)
    }

    // MARK: - Page 4: Enable Keyboard
    private var page4: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .blur(radius: 50)
                Circle()
                    .fill(LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 96, height: 96)
                Image(systemName: "keyboard.badge.ellipsis.fill")
                    .font(.system(size: 42, weight: .medium))
                    .foregroundColor(.white)
            }

            VStack(spacing: 10) {
                Text("Enable Your Keyboard")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                Text("Follow these steps — takes less than 30 seconds")
                    .font(.system(size: 15))
                    .foregroundColor(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 32)

            VStack(spacing: 8) {
                ob4Step(1, "Open Settings → General → Keyboard")
                ob4Step(2, "Tap \"Keyboards\" → \"Add New Keyboard\"")
                ob4Step(3, "Select \"KeyboardAI\" from the list")
                ob4Step(4, "Enable \"Allow Full Access\" → tap Allow")
            }
            .padding(.horizontal, 24)

            if showContinueButton {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                    Text("All set! Keyboard is active.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(Color.green.opacity(0.15))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.green.opacity(0.3), lineWidth: 1))
                .padding(.horizontal, 24)
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            }

            Spacer()
        }
    }

    private func ob4Step(_ n: Int, _ text: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(showContinueButton ? Color.green : Color.orange)
                    .frame(width: 32, height: 32)
                if showContinueButton {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    Text("\(n)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .animation(.spring(), value: showContinueButton)

            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Color.white.opacity(0.06))
        .cornerRadius(12)
    }
}
