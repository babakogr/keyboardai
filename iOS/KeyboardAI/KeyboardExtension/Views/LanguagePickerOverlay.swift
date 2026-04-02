import SwiftUI

struct LanguagePickerOverlay: View {
    @ObservedObject var viewModel: KeyboardViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.showLanguagePicker = false
                    }
                }
            
            // Language grid
            VStack(spacing: 12) {
                HStack {
                    Text("Select Language")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.kbLabel)
                    Spacer()
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.2)) {
                            viewModel.showLanguagePicker = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.kbSecondaryLabel)
                    }
                }
                
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(Configuration.supportedLanguages, id: \.code) { lang in
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            viewModel.setLanguage(lang.code)
                        }) {
                            VStack(spacing: 4) {
                                Text(lang.flag)
                                    .font(.system(size: 22))
                                Text(lang.code)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(viewModel.selectedLanguage == lang.code ? .white : .kbLabel)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                viewModel.selectedLanguage == lang.code
                                    ? AnyShapeStyle(LinearGradient(colors: [.kbGradientStart, .kbGradientEnd], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    : AnyShapeStyle(KeyboardTheme.chipBackground)
                            )
                            .cornerRadius(10)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.kbBackground)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 5)
            .padding(.horizontal, 12)
        }
        .transition(.opacity)
    }
}
