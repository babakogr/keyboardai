import SwiftUI

struct AIReplyBar: View {
    @ObservedObject var viewModel: KeyboardViewModel
    
    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 11))
                    .foregroundColor(.kbAccent)
                Text("AI Replies")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.kbAccent)
                Spacer()
                Button(action: {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.aiReplies = []
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.kbSecondaryLabel)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 6)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.aiReplies, id: \.self) { reply in
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            viewModel.selectReply(reply)
                        }) {
                            Text(reply)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        colors: [.kbGradientStart, .kbGradientEnd],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(18)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 6)
        }
        .background(Color.kbAccentLight)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
