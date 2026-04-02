import SwiftUI

struct ChatTestView: View {
    @State private var inputText = ""
    @State private var messages: [ChatMessage] = ChatMessage.defaults
    @State private var showTip = true
    @FocusState private var isFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                Color.kbBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Message list
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                if showTip { tipBanner }

                                LazyVStack(spacing: 12) {
                                    ForEach(messages) { msg in
                                        messageBubble(msg)
                                            .id(msg.id)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 8)

                                keyboardGuideCard
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 16)

                                Color.clear.frame(height: 1).id("bottom")
                            }
                        }
                        .scrollDismissesKeyboard(.interactively)
                        .onTapGesture { isFocused = false }
                        .onChange(of: messages.count) { _ in
                            withAnimation { proxy.scrollTo("bottom") }
                        }
                    }

                    Divider()

                    // Input bar
                    HStack(alignment: .bottom, spacing: 10) {
                        TextField("Type here and switch to KeyboardAI...", text: $inputText, axis: .vertical)
                            .font(.system(size: 15))
                            .foregroundColor(.kbLabel)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(22)
                            .lineLimit(1...5)
                            .focused($isFocused)

                        if !inputText.trimmingCharacters(in: .whitespaces).isEmpty {
                            Button(action: sendMessage) {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.kbGradientStart, .kbGradientEnd],
                                            startPoint: .topLeading, endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Try It")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isFocused {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer()
                        Button("Done") { isFocused = false }
                            .font(.system(size: 15, weight: .semibold))
                    }
                }
            }
        }
    }

    // MARK: - Tip Banner
    private var tipBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .font(.system(size: 17))
                .foregroundColor(.orange)

            VStack(alignment: .leading, spacing: 3) {
                Text("How to use KeyboardAI")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.kbLabel)
                Text("Tap the 🌐 globe key while typing to switch to KeyboardAI keyboard")
                    .font(.system(size: 12))
                    .foregroundColor(.kbSecondaryLabel)
                    .lineSpacing(2)
            }

            Spacer()

            Button(action: { withAnimation(.easeOut) { showTip = false } }) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.kbSecondaryLabel)
                    .padding(6)
                    .background(Color.kbSeparator.opacity(0.3))
                    .clipShape(Circle())
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.08))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.18), lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Message Bubble
    private func messageBubble(_ msg: ChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if msg.isUser {
                Spacer(minLength: 56)
                Text(msg.text)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.kbGradientStart, .kbGradientEnd],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(18)
                    .cornerRadius(4, corners: .bottomRight)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    if let label = msg.label {
                        Text(label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.kbAccent)
                            .padding(.leading, 4)
                    }
                    Text(msg.text)
                        .font(.system(size: 15))
                        .foregroundColor(.kbLabel)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.kbSecondaryBg)
                        .cornerRadius(18)
                        .cornerRadius(4, corners: .bottomLeft)
                }
                Spacer(minLength: 56)
            }
        }
    }

    // MARK: - Keyboard Guide Card
    private var keyboardGuideCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "keyboard.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.kbAccent)
                Text("KeyboardAI Features")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.kbLabel)
            }

            VStack(spacing: 10) {
                guideRow("🌍", "Translate", "Translate selected text into 14 languages instantly")
                guideRow("✨", "Improve", "Rewrite your text to sound professional and polished")
                guideRow("✅", "Fix", "Auto-correct grammar, spelling and punctuation")
                guideRow("💬", "Reply", "Generate 3 smart reply options for any message")
            }
        }
        .padding(16)
        .background(Color.kbSecondaryBg)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func guideRow(_ emoji: String, _ title: String, _ desc: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(emoji).font(.system(size: 20)).frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.kbLabel)
                Text(desc)
                    .font(.system(size: 12))
                    .foregroundColor(.kbSecondaryLabel)
                    .lineSpacing(2)
            }
            Spacer()
        }
    }

    // MARK: - Actions
    private func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        withAnimation(.spring(response: 0.3)) {
            messages.append(ChatMessage(text: text, isUser: true))
        }
        inputText = ""
        isFocused = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.spring(response: 0.4)) {
                messages.append(ChatMessage(
                    text: "Great! Now try switching to KeyboardAI keyboard (tap 🌐 globe) and use Improve or Translate on your message.",
                    isUser: false,
                    label: "KeyboardAI"
                ))
            }
        }
    }
}

// MARK: - Models
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    var label: String? = nil

    static let defaults: [ChatMessage] = [
        ChatMessage(
            text: "👋 Welcome to the KeyboardAI test area! Type anything below and I'll show you how the AI keyboard works.",
            isUser: false,
            label: "KeyboardAI"
        ),
        ChatMessage(
            text: "You can test translation, grammar fixes, text improvement and smart replies — all from the keyboard.",
            isUser: false,
            label: "KeyboardAI"
        ),
        ChatMessage(
            text: "Try typing something like: \"i want to go meeting tomorrow please confirm\" — then tap Improve in the keyboard!",
            isUser: false,
            label: "KeyboardAI"
        )
    ]
}

// MARK: - Corner Radius Helper
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
