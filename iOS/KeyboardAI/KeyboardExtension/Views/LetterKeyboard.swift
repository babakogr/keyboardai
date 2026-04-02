import SwiftUI

struct LetterKeyboard: View {
    @ObservedObject var viewModel: KeyboardViewModel
    
    private let row1 = ["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"]
    private let row2 = ["a", "s", "d", "f", "g", "h", "j", "k", "l"]
    private let row3 = ["z", "x", "c", "v", "b", "n", "m"]
    
    private func displayChar(_ char: String) -> String {
        switch viewModel.shiftState {
        case .off: return char
        case .on, .capsLock: return char.uppercased()
        }
    }
    
    private func outputChar(_ char: String) -> String {
        switch viewModel.shiftState {
        case .off: return char
        case .on, .capsLock: return char.uppercased()
        }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Row 1
            HStack(spacing: 5) {
                ForEach(row1, id: \.self) { key in
                    KeyButton(
                        label: displayChar(key),
                        action: { viewModel.insertCharacter(outputChar(key)) }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 3)
            
            // Row 2
            HStack(spacing: 5) {
                Spacer(minLength: 14)
                ForEach(row2, id: \.self) { key in
                    KeyButton(
                        label: displayChar(key),
                        action: { viewModel.insertCharacter(outputChar(key)) }
                    )
                    .frame(maxWidth: .infinity)
                }
                Spacer(minLength: 14)
            }
            .padding(.horizontal, 3)
            
            // Row 3 (with shift and delete)
            HStack(spacing: 5) {
                // Shift key
                IconKeyButton(
                    icon: viewModel.shiftState == .capsLock
                        ? "capslock.fill"
                        : (viewModel.shiftState == .on ? "shift.fill" : "shift"),
                    action: { viewModel.toggleShift() },
                    width: 42,
                    isHighlighted: viewModel.shiftState != .off
                )
                .simultaneousGesture(
                    TapGesture(count: 2).onEnded {
                        viewModel.handleDoubleTapShift()
                    }
                )
                
                ForEach(row3, id: \.self) { key in
                    KeyButton(
                        label: displayChar(key),
                        action: { viewModel.insertCharacter(outputChar(key)) }
                    )
                    .frame(maxWidth: .infinity)
                }
                
                // Delete key
                IconKeyButton(
                    icon: "delete.left",
                    action: { viewModel.deleteBackward() },
                    width: 42
                )
            }
            .padding(.horizontal, 3)
            
            // Row 4 (bottom row)
            HStack(spacing: 5) {
                // 123 key
                KeyButton(
                    label: "123",
                    action: { viewModel.switchToNumbers() },
                    width: 42,
                    fontSize: 15,
                    isSpecial: true
                )
                
                // Globe key
                IconKeyButton(
                    icon: "globe",
                    action: { viewModel.switchKeyboard() },
                    width: 42
                )
                
                // Space bar
                SpaceBarButton(action: { viewModel.insertSpace() })
                
                // Return key
                KeyButton(
                    label: "return",
                    action: { viewModel.insertReturn() },
                    width: 88,
                    fontSize: 15,
                    isSpecial: true,
                    specialColor: KeyboardTheme.actionKeyBg
                )
            }
            .padding(.horizontal, 3)
        }
        .padding(.vertical, 4)
        .padding(.bottom, 2)
    }
}
