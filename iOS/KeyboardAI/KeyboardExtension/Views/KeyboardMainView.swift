import SwiftUI

struct KeyboardMainView: View {
    @ObservedObject var viewModel: KeyboardViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // AI Action Bar (top row)
            AIActionBar(viewModel: viewModel)
            
            // AI Reply Options (when available)
            if !viewModel.aiReplies.isEmpty {
                AIReplyBar(viewModel: viewModel)
            }
            
            // Suggestion Chips (second row)
            SuggestionChipsBar(viewModel: viewModel)
            
            // Error / Processing overlay
            if viewModel.isProcessing {
                ProcessingBar()
            } else if viewModel.showError {
                ErrorBar(message: viewModel.errorMessage)
            } else if viewModel.showUpgradePrompt {
                UpgradePromptBar(viewModel: viewModel)
            }
            
            // Keyboard Layout
            switch viewModel.keyboardMode {
            case .letters:
                LetterKeyboard(viewModel: viewModel)
            case .numbers:
                NumberKeyboard(viewModel: viewModel)
            case .symbols:
                SymbolKeyboard(viewModel: viewModel)
            }
        }
        .background(KeyboardTheme.keyboardBackground)
        // Language Picker Overlay
        .overlay {
            if viewModel.showLanguagePicker {
                LanguagePickerOverlay(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Processing Bar
struct ProcessingBar: View {
    @State private var dotCount = 0

    var body: some View {
        HStack(spacing: 8) {
            ProgressView()
                .scaleEffect(0.8)
                .tint(.kbAccent)

            Text("AI is thinking" + String(repeating: ".", count: dotCount))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.kbAccent)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.kbAccent.opacity(0.12))
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 400_000_000)
                dotCount = (dotCount + 1) % 4
            }
        }
    }
}

// MARK: - Error Bar
struct ErrorBar: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 5)
            .background(Color.red.opacity(0.08))
            .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - Upgrade Prompt Bar
struct UpgradePromptBar: View {
    @ObservedObject var viewModel: KeyboardViewModel
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.system(size: 13))
                .foregroundColor(.kbGradientEnd)
            
            Text("Daily limit reached. Open app to upgrade.")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.kbLabel)
            
            Spacer()
            
            Button(action: { viewModel.showUpgradePrompt = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.kbSecondaryLabel)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [Color.kbGradientStart.opacity(0.1), Color.kbGradientEnd.opacity(0.1)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
