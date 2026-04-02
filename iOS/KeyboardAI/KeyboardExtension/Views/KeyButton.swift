import SwiftUI

// MARK: - Standard Key
struct KeyButton: View {
    let label: String
    let action: () -> Void
    var width: CGFloat? = nil
    var fontSize: CGFloat = 22
    var isSpecial: Bool = false
    var specialColor: Color? = nil
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text(label)
                .font(.system(size: fontSize, weight: isSpecial ? .medium : .regular))
                .foregroundColor(isSpecial ? (specialColor != nil ? .white : KeyboardTheme.keyText) : KeyboardTheme.keyText)
                .frame(minWidth: width ?? 32, maxHeight: .infinity)
                .frame(height: 42)
                .background(
                    isSpecial
                        ? (specialColor != nil ? AnyShapeStyle(specialColor!) : AnyShapeStyle(KeyboardTheme.keyHighlight))
                        : AnyShapeStyle(KeyboardTheme.keyBackground)
                )
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Icon Key
struct IconKeyButton: View {
    let icon: String
    let action: () -> Void
    var width: CGFloat? = nil
    var isHighlighted: Bool = false
    var highlightColor: Color = KeyboardTheme.actionKeyBg
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isHighlighted ? .white : KeyboardTheme.keyText)
                .frame(minWidth: width ?? 42, maxHeight: .infinity)
                .frame(height: 42)
                .background(isHighlighted ? highlightColor : KeyboardTheme.keyHighlight)
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Space Bar
struct SpaceBarButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            action()
        }) {
            Text("space")
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(KeyboardTheme.keyText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 42)
                .background(KeyboardTheme.keyBackground)
                .cornerRadius(5)
                .shadow(color: .black.opacity(0.15), radius: 0, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}
