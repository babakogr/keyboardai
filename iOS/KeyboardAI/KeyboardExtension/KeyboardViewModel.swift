import Foundation
import UIKit
import SwiftUI

enum KeyboardMode {
    case letters
    case numbers
    case symbols
}

enum ShiftState {
    case off
    case on
    case capsLock
}

@MainActor
final class KeyboardViewModel: ObservableObject {
    // MARK: - Text Proxy
    var inputProxy: UITextDocumentProxy?
    var advanceToNextInput: (() -> Void)?
    
    // MARK: - Keyboard State
    @Published var keyboardMode: KeyboardMode = .letters
    @Published var shiftState: ShiftState = .on // Start with shift on (first letter capitalized)
    @Published var currentText: String = ""
    
    // MARK: - AI State
    @Published var isProcessing: Bool = false
    @Published var aiResult: String?
    @Published var aiReplies: [String] = []
    @Published var suggestions: [String] = ["Sure", "Okay", "Sounds good", "😂 Haha", "💼 Of course"]
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showLanguagePicker: Bool = false
    @Published var showUpgradePrompt: Bool = false
    
    // MARK: - Language
    @Published var selectedLanguage: String
    
    private let aiService = AIService.shared
    
    init() {
        // Defensive: UserDefaults(suiteName:) can return nil if app group isn't configured
        if let defaults = UserDefaults(suiteName: Configuration.appGroupIdentifier),
           let lang = defaults.string(forKey: Configuration.udKeySelectedLanguage) {
            self.selectedLanguage = lang
        } else {
            self.selectedLanguage = "EN"
        }
    }
    
    // MARK: - Current Text from Proxy
    func updateCurrentText() {
        guard let proxy = inputProxy else { return }
        let before = proxy.documentContextBeforeInput ?? ""
        let after = proxy.documentContextAfterInput ?? ""
        currentText = before + after
    }
    
    // MARK: - Text Input Actions
    func insertCharacter(_ char: String) {
        inputProxy?.insertText(char)
        
        // Auto-disable shift after typing a letter (unless caps lock)
        if shiftState == .on {
            shiftState = .off
        }
        
        updateCurrentText()
    }
    
    func deleteBackward() {
        inputProxy?.deleteBackward()
        updateCurrentText()
    }
    
    func insertSpace() {
        inputProxy?.insertText(" ")
        updateCurrentText()
    }
    
    func insertReturn() {
        inputProxy?.insertText("\n")
        updateCurrentText()
    }
    
    func toggleShift() {
        switch shiftState {
        case .off: shiftState = .on
        case .on: shiftState = .off
        case .capsLock: shiftState = .off
        }
    }
    
    func handleDoubleTapShift() {
        shiftState = .capsLock
    }
    
    func switchToNumbers() {
        keyboardMode = keyboardMode == .numbers ? .letters : .numbers
    }
    
    func switchToSymbols() {
        keyboardMode = keyboardMode == .symbols ? .numbers : .symbols
    }
    
    func switchKeyboard() {
        advanceToNextInput?()
    }
    
    // MARK: - Replace All Text
    private func replaceAllText(with newText: String) {
        guard let proxy = inputProxy else { return }
        
        // Select all text by moving to end then deleting everything
        // Move cursor to end
        if let after = proxy.documentContextAfterInput {
            proxy.adjustTextPosition(byCharacterOffset: after.count)
        }
        
        // Delete all text before cursor
        if let before = proxy.documentContextBeforeInput {
            for _ in 0..<before.count {
                proxy.deleteBackward()
            }
        }
        
        // Insert new text
        proxy.insertText(newText)
        updateCurrentText()
    }
    
    // MARK: - Get Full Text
    private func getFullText() -> String {
        updateCurrentText()
        return currentText.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - AI Actions
    func performTranslate() {
        let text = getFullText()
        guard !text.isEmpty else {
            showErrorBriefly("Type something to translate")
            return
        }
        
        guard checkUsageLimit() else { return }
        
        isProcessing = true
        aiResult = nil
        
        Task {
            do {
                let result = try await aiService.translate(text: text, targetLang: selectedLanguage)
                replaceAllText(with: result)
                isProcessing = false
            } catch {
                handleAIError(error)
            }
        }
    }
    
    func performImprove() {
        let text = getFullText()
        guard !text.isEmpty else {
            showErrorBriefly("Type something to improve")
            return
        }
        
        guard checkUsageLimit() else { return }
        
        isProcessing = true
        
        Task {
            do {
                let result = try await aiService.improve(text: text)
                replaceAllText(with: result)
                isProcessing = false
            } catch {
                handleAIError(error)
            }
        }
    }
    
    func performFix() {
        let text = getFullText()
        guard !text.isEmpty else {
            showErrorBriefly("Type something to fix")
            return
        }
        
        guard checkUsageLimit() else { return }
        
        isProcessing = true
        
        Task {
            do {
                let result = try await aiService.fix(text: text)
                replaceAllText(with: result)
                isProcessing = false
            } catch {
                handleAIError(error)
            }
        }
    }
    
    func performReply() {
        let text = getFullText()
        guard !text.isEmpty else {
            showErrorBriefly("Paste a message to generate replies")
            return
        }
        
        guard checkUsageLimit() else { return }
        
        isProcessing = true
        aiReplies = []
        
        Task {
            do {
                let replies = try await aiService.generateReplies(text: text)
                aiReplies = replies
                isProcessing = false
            } catch {
                handleAIError(error)
            }
        }
    }
    
    func selectReply(_ reply: String) {
        replaceAllText(with: reply)
        aiReplies = []
    }
    
    func insertSuggestion(_ suggestion: String) {
        inputProxy?.insertText(suggestion)
        updateCurrentText()
    }
    
    func loadSuggestions() {
        let text = getFullText()
        guard !text.isEmpty else { return }
        
        Task {
            do {
                let newSuggestions = try await aiService.getSuggestions(text: text)
                if !newSuggestions.isEmpty {
                    suggestions = newSuggestions
                }
            } catch {
                // Silently fail - keep default suggestions
            }
        }
    }
    
    func setLanguage(_ code: String) {
        selectedLanguage = code
        let defaults = UserDefaults(suiteName: Configuration.appGroupIdentifier)
        defaults?.set(code, forKey: Configuration.udKeySelectedLanguage)
        showLanguagePicker = false
    }
    
    // MARK: - Helpers
    private func checkUsageLimit() -> Bool {
        if UsageTracker.shared.hasReachedFreeLimit {
            showUpgradePrompt = true
            return false
        }
        return true
    }
    
    private func handleAIError(_ error: Error) {
        isProcessing = false
        if let apiError = error as? APIError {
            switch apiError {
            case .freeLimitReached:
                showUpgradePrompt = true
            default:
                showErrorBriefly(apiError.localizedDescription)
            }
        } else {
            showErrorBriefly("Something went wrong. Try again.")
        }
    }
    
    private func showErrorBriefly(_ message: String) {
        errorMessage = message
        showError = true
        
        Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            showError = false
        }
    }
}
