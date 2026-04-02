import Foundation

struct AuthResponse: Codable {
    let token: String
    let tier: String
    let expiresIn: String?
    let dailyLimit: Int?
}

final class AuthManager {
    static let shared = AuthManager()
    private init() {}
    
    private let keychain = KeychainManager.shared
    
    // MARK: - Device ID
    func getDeviceId() -> String {
        if let existing = keychain.read(key: Configuration.keychainDeviceIdKey) {
            return existing
        }
        
        // Generate a stable device ID using UUID stored in keychain
        let newId = UUID().uuidString
        keychain.save(key: Configuration.keychainDeviceIdKey, value: newId)
        return newId
    }
    
    // MARK: - Token Management
    func getToken() -> String? {
        return keychain.read(key: Configuration.keychainTokenKey)
    }
    
    func saveToken(_ token: String) {
        keychain.save(key: Configuration.keychainTokenKey, value: token)
    }
    
    func clearToken() {
        keychain.delete(key: Configuration.keychainTokenKey)
    }
    
    // MARK: - User Tier
    func getUserTier() -> String {
        let defaults = UserDefaults(suiteName: Configuration.appGroupIdentifier)
        return defaults?.string(forKey: Configuration.udKeyTier) ?? "free"
    }
    
    func setUserTier(_ tier: String) {
        let defaults = UserDefaults(suiteName: Configuration.appGroupIdentifier)
        defaults?.set(tier, forKey: Configuration.udKeyTier)
    }
    
    var isPro: Bool {
        return getUserTier() == "pro"
    }
    
    // MARK: - Register Device
    func register() async throws {
        let deviceId = getDeviceId()
        
        guard let url = URL(string: "\(Configuration.apiBaseURL)/auth/register") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
        
        let body: [String: Any] = [
            "deviceId": deviceId,
            "bundleId": Configuration.mainAppBundleId
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let authResponse = try decoder.decode(AuthResponse.self, from: data)
        
        saveToken(authResponse.token)
        setUserTier(authResponse.tier)
    }
    
    // MARK: - Refresh Token
    func refreshToken() async throws -> Bool {
        guard let currentToken = getToken() else { return false }
        
        guard let url = URL(string: "\(Configuration.apiBaseURL)/auth/refresh") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(currentToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            return false
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let authResponse = try decoder.decode(AuthResponse.self, from: data)
        
        saveToken(authResponse.token)
        setUserTier(authResponse.tier)
        return true
    }
    
    // MARK: - Upgrade to Pro
    func upgradeToPro(receipt: String) async throws {
        guard let url = URL(string: "\(Configuration.apiBaseURL)/auth/upgrade") else {
            throw APIError.invalidURL
        }
        
        guard let token = getToken() else {
            throw APIError.unauthorized
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "receipt": receipt,
            "tier": "pro"
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let authResponse = try decoder.decode(AuthResponse.self, from: data)
        
        saveToken(authResponse.token)
        setUserTier(authResponse.tier)
    }
}
