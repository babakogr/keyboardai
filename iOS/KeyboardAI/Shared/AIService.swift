import Foundation

// MARK: - Response Models
struct TranslateResponse: Codable {
    let result: String
    let detectedLang: String?
    let provider: String?
    let fromCache: Bool?
}

struct TextResponse: Codable {
    let result: String
    let fromCache: Bool?
}

struct ReplyResponse: Codable {
    let replies: [String]
    let fromCache: Bool?
}

struct SuggestionsResponse: Codable {
    let suggestions: [String]
    let fromCache: Bool?
}

// MARK: - AI Action Types
enum AIAction: String, CaseIterable {
    case translate
    case improve
    case fix
    case reply
    case suggestions
    
    var displayName: String {
        switch self {
        case .translate: return "Translate"
        case .improve: return "Improve"
        case .fix: return "Fix"
        case .reply: return "Reply"
        case .suggestions: return "Suggest"
        }
    }
    
    var icon: String {
        switch self {
        case .translate: return "globe"
        case .improve: return "sparkles"
        case .fix: return "checkmark.circle"
        case .reply: return "bubble.left.and.bubble.right"
        case .suggestions: return "text.bubble"
        }
    }
    
    var emoji: String {
        switch self {
        case .translate: return "🌍"
        case .improve: return "✨"
        case .fix: return "✅"
        case .reply: return "💬"
        case .suggestions: return "💡"
        }
    }
}

// MARK: - AI Service
final class AIService {
    static let shared = AIService()
    private init() {}
    
    private let network = NetworkManager.shared
    
    // Local response cache for the keyboard session
    private var sessionCache: [String: Any] = [:]
    
    // MARK: - Translate
    func translate(text: String, targetLang: String) async throws -> String {
        let cacheKey = "translate:\(text):\(targetLang)"
        if let cached = sessionCache[cacheKey] as? String { return cached }
        
        let body: [String: Any] = ["text": text, "targetLang": targetLang]
        let response: TranslateResponse = try await network.request(
            endpoint: "ai/translate",
            body: body
        )
        
        UsageTracker.shared.incrementUsage()
        sessionCache[cacheKey] = response.result
        return response.result
    }
    
    // MARK: - Improve
    func improve(text: String) async throws -> String {
        let cacheKey = "improve:\(text)"
        if let cached = sessionCache[cacheKey] as? String { return cached }
        
        let body: [String: Any] = ["text": text]
        let response: TextResponse = try await network.request(
            endpoint: "ai/improve",
            body: body
        )
        
        UsageTracker.shared.incrementUsage()
        sessionCache[cacheKey] = response.result
        return response.result
    }
    
    // MARK: - Fix Grammar
    func fix(text: String) async throws -> String {
        let cacheKey = "fix:\(text)"
        if let cached = sessionCache[cacheKey] as? String { return cached }
        
        let body: [String: Any] = ["text": text]
        let response: TextResponse = try await network.request(
            endpoint: "ai/fix",
            body: body
        )
        
        UsageTracker.shared.incrementUsage()
        sessionCache[cacheKey] = response.result
        return response.result
    }
    
    // MARK: - Generate Replies
    func generateReplies(text: String) async throws -> [String] {
        let cacheKey = "reply:\(text)"
        if let cached = sessionCache[cacheKey] as? [String] { return cached }
        
        let body: [String: Any] = ["text": text]
        let response: ReplyResponse = try await network.request(
            endpoint: "ai/reply",
            body: body
        )
        
        UsageTracker.shared.incrementUsage()
        sessionCache[cacheKey] = response.replies
        return response.replies
    }
    
    // MARK: - Get Suggestions
    func getSuggestions(text: String) async throws -> [String] {
        let cacheKey = "suggestions:\(text)"
        if let cached = sessionCache[cacheKey] as? [String] { return cached }
        
        let body: [String: Any] = ["text": text]
        let response: SuggestionsResponse = try await network.request(
            endpoint: "ai/suggestions",
            body: body
        )
        
        sessionCache[cacheKey] = response.suggestions
        return response.suggestions
    }
    
    // MARK: - Clear Session Cache
    func clearSessionCache() {
        sessionCache.removeAll()
    }
}
