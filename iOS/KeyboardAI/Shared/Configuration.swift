import Foundation

enum Configuration {
    // MARK: - API Configuration
    // Point this to your deployed backend URL
    static let apiBaseURL = "https://your-backend-url.com/api"
    
    // MARK: - App Group (shared between main app and keyboard extension)
    static let appGroupIdentifier = "group.com.keyboardai.app"
    
    // MARK: - Bundle IDs
    static let mainAppBundleId = "com.keyboardai.app"
    static let keyboardBundleId = "com.keyboardai.app.keyboard"
    
    // MARK: - Keychain
    static let keychainServiceName = "com.keyboardai.auth"
    static let keychainTokenKey = "jwt_token"
    static let keychainDeviceIdKey = "device_id"
    
    // MARK: - UserDefaults Keys
    static let udKeyTier = "user_tier"
    static let udKeySelectedLanguage = "selected_language"
    static let udKeyDailyUsageCount = "daily_usage_count"
    static let udKeyLastUsageDate = "last_usage_date"
    static let udKeyOnboardingCompleted = "onboarding_completed"
    static let udKeyHasFullAccess = "has_full_access"
    
    // MARK: - Limits
    static let freeDailyLimit = 3
    static let maxInputLength = 500
    
    // MARK: - Supported Languages
    static let supportedLanguages: [(code: String, name: String, flag: String)] = [
        ("EN", "English", "🇺🇸"),
        ("TR", "Türkçe", "🇹🇷"),
        ("DE", "Deutsch", "🇩🇪"),
        ("FR", "Français", "🇫🇷"),
        ("ES", "Español", "🇪🇸"),
        ("IT", "Italiano", "🇮🇹"),
        ("PT", "Português", "🇧🇷"),
        ("RU", "Русский", "🇷🇺"),
        ("JA", "日本語", "🇯🇵"),
        ("KO", "한국어", "🇰🇷"),
        ("ZH", "中文", "🇨🇳"),
        ("AR", "العربية", "🇸🇦"),
        ("NL", "Nederlands", "🇳🇱"),
        ("PL", "Polski", "🇵🇱")
    ]
}
