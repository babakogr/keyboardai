import Foundation

final class UsageTracker {
    static let shared = UsageTracker()
    private init() {}
    
    private var defaults: UserDefaults? {
        UserDefaults(suiteName: Configuration.appGroupIdentifier)
    }
    
    // MARK: - Daily Usage (local tracking for free tier UI)
    var dailyUsageCount: Int {
        get {
            let lastDate = defaults?.string(forKey: Configuration.udKeyLastUsageDate) ?? ""
            let today = todayString()
            
            if lastDate != today {
                // New day - reset count
                defaults?.set(0, forKey: Configuration.udKeyDailyUsageCount)
                defaults?.set(today, forKey: Configuration.udKeyLastUsageDate)
                return 0
            }
            
            return defaults?.integer(forKey: Configuration.udKeyDailyUsageCount) ?? 0
        }
    }
    
    var remainingFreeUses: Int {
        return max(0, Configuration.freeDailyLimit - dailyUsageCount)
    }
    
    var hasReachedFreeLimit: Bool {
        return !AuthManager.shared.isPro && dailyUsageCount >= Configuration.freeDailyLimit
    }
    
    func incrementUsage() {
        let today = todayString()
        let lastDate = defaults?.string(forKey: Configuration.udKeyLastUsageDate) ?? ""
        
        if lastDate != today {
            defaults?.set(1, forKey: Configuration.udKeyDailyUsageCount)
            defaults?.set(today, forKey: Configuration.udKeyLastUsageDate)
        } else {
            let current = defaults?.integer(forKey: Configuration.udKeyDailyUsageCount) ?? 0
            defaults?.set(current + 1, forKey: Configuration.udKeyDailyUsageCount)
        }
    }
    
    func updateRemaining(_ remaining: Int) {
        // Server-side remaining count - sync with local tracking
    }
    
    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
