import SwiftUI

struct NumberKeyboard: View {
    @ObservedObject var viewModel: KeyboardViewModel
    
    private let row1 = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
    private let row2 = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
    private let row3 = [".", ",", "?", "!", "'"]
    
    var body: some View {
        VStack(spacing: 6) {
            // Row 1
            HStack(spacing: 5) {
                ForEach(row1, id: \.self) { key in
                    KeyButton(
                        label: key,
                        action: { viewModel.insertCharacter(key) }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 3)
            
            // Row 2
            HStack(spacing: 5) {
                ForEach(row2, id: \.self) { key in
                    KeyButton(
                        label: key,
                        action: { viewModel.insertCharacter(key) }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 3)
            
            // Row 3 (with symbols switch and delete)
            HStack(spacing: 5) {
                // Symbols switch
                KeyButton(
                    label: "#+=",
                    action: { viewModel.switchToSymbols() },
                    width: 42,
                    fontSize: 15,
                    isSpecial: true
                )
                
                ForEach(row3, id: \.self) { key in
                    KeyButton(
                        label: key,
                        action: { viewModel.insertCharacter(key) }
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
                // ABC key
                KeyButton(
                    label: "ABC",
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
