import SwiftUI

struct SuggestionChipsBar: View {
    @ObservedObject var viewModel: KeyboardViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.suggestions, id: \.self) { suggestion in
                    Button(action: {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        viewModel.insertSuggestion(suggestion)
                    }) {
                        Text(suggestion)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.kbLabel)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(KeyboardTheme.chipBackground)
                            .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 36)
    }
}
