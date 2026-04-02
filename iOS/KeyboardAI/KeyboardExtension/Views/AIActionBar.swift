import SwiftUI

struct AIActionBar: View {
    @ObservedObject var viewModel: KeyboardViewModel
    
    var body: some View {
        HStack(spacing: 6) {
            // Language button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.showLanguagePicker.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Text(flagForCode(viewModel.selectedLanguage))
                        .font(.system(size: 16))
                    Text(viewModel.selectedLanguage)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.kbLabel)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(KeyboardTheme.chipBackground)
                .cornerRadius(8)
            }
            
            Divider()
                .frame(height: 20)
                .padding(.horizontal, 2)
            
            // Translate button
            aiButton(
                icon: "🌍",
                label: "Translate",
                action: viewModel.performTranslate
            )
            
            // Improve button
            aiButton(
                icon: "✨",
                label: "Improve",
                action: viewModel.performImprove
            )
            
            // Reply button
            aiButton(
                icon: "💬",
                label: "Reply",
                action: viewModel.performReply
            )
            
            // Fix button
            aiButton(
                icon: "✅",
                label: "Fix",
                action: viewModel.performFix
            )
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - AI Button
    private func aiButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            action()
        }) {
            VStack(spacing: 2) {
                Text(icon)
                    .font(.system(size: 14))
                Text(label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.kbLabel)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(KeyboardTheme.chipBackground)
            .cornerRadius(8)
        }
        .disabled(viewModel.isProcessing)
        .opacity(viewModel.isProcessing ? 0.5 : 1.0)
    }
    
    // MARK: - Flag Helper
    private func flagForCode(_ code: String) -> String {
        Configuration.supportedLanguages.first(where: { $0.code == code })?.flag ?? "🌍"
    }
}
