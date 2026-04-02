import SwiftUI

// MARK: - Color Theme
extension Color {
    static let kbPrimary = Color(red: 0.35, green: 0.47, blue: 1.0)
    static let kbBackground = Color(UIColor.systemBackground)
    static let kbSecondaryBg = Color(UIColor.secondarySystemBackground)
    static let kbTertiaryBg = Color(UIColor.tertiarySystemBackground)
    static let kbLabel = Color(UIColor.label)
    static let kbSecondaryLabel = Color(UIColor.secondaryLabel)
    static let kbSeparator = Color(UIColor.separator)
    
    // Brand colors
    static let kbAccent = Color(red: 0.35, green: 0.47, blue: 1.0)
    static let kbAccentLight = Color(red: 0.35, green: 0.47, blue: 1.0).opacity(0.12)
    static let kbSuccess = Color(red: 0.25, green: 0.78, blue: 0.47)
    static let kbWarning = Color(red: 1.0, green: 0.76, blue: 0.03)
    static let kbGradientStart = Color(red: 0.35, green: 0.47, blue: 1.0)
    static let kbGradientEnd = Color(red: 0.58, green: 0.35, blue: 1.0)
}

// MARK: - Keyboard Theme Colors
struct KeyboardTheme {
    static let keyBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.25, green: 0.25, blue: 0.27, alpha: 1)
            : UIColor.white
    })
    
    static let keyHighlight = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.35, green: 0.35, blue: 0.37, alpha: 1)
            : UIColor(red: 0.68, green: 0.70, blue: 0.74, alpha: 1)
    })
    
    static let keyboardBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.13, alpha: 1)
            : UIColor(red: 0.82, green: 0.84, blue: 0.86, alpha: 1)
    })
    
    static let keyText = Color(UIColor.label)
    static let actionKeyBg = Color(red: 0.35, green: 0.47, blue: 1.0)
    static let actionKeyText = Color.white
    static let chipBackground = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.22, green: 0.23, blue: 0.28, alpha: 1)
            : UIColor(red: 0.93, green: 0.94, blue: 0.97, alpha: 1)
    })
}

// MARK: - Font Styles
extension Font {
    static let kbTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let kbHeadline = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let kbBody = Font.system(size: 16, weight: .regular, design: .default)
    static let kbCaption = Font.system(size: 13, weight: .regular, design: .default)
    static let kbChip = Font.system(size: 14, weight: .medium, design: .rounded)
    static let kbKey = Font.system(size: 22, weight: .regular, design: .default)
    static let kbSmallKey = Font.system(size: 16, weight: .medium, design: .default)
}

// MARK: - View Modifiers
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(Color.kbSecondaryBg)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyleConfiguration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.kbGradientStart, .kbGradientEnd],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(14)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
