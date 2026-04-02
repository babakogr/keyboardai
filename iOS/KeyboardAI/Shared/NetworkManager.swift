import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int, String)
    case decodingError
    case noData
    case rateLimited(String)
    case freeLimitReached(String)
    case unauthorized
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .invalidResponse: return "Invalid response"
        case .httpError(let code, let msg): return "Error \(code): \(msg)"
        case .decodingError: return "Failed to decode response"
        case .noData: return "No data received"
        case .rateLimited(let msg): return msg
        case .freeLimitReached(let msg): return msg
        case .unauthorized: return "Authentication required"
        case .networkError(let msg): return msg
        }
    }
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    private let baseURL: String
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
        self.baseURL = Configuration.apiBaseURL
    }
    
    // MARK: - Generic Request
    func request<T: Decodable>(
        endpoint: String,
        method: String = "POST",
        body: [String: Any]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Configuration.keyboardBundleId, forHTTPHeaderField: "X-Bundle-ID")
        
        // Add device ID
        let deviceId = AuthManager.shared.getDeviceId()
        request.setValue(deviceId, forHTTPHeaderField: "X-Device-ID")
        
        // Add auth token if required
        if requiresAuth {
            guard let token = AuthManager.shared.getToken() else {
                // Try to register first
                try await AuthManager.shared.register()
                guard let newToken = AuthManager.shared.getToken() else {
                    throw APIError.unauthorized
                }
                request.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                return try await executeRequest(request, body: body)
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return try await executeRequest(request, body: body)
    }
    
    private func executeRequest<T: Decodable>(
        _ request: URLRequest,
        body: [String: Any]?
    ) async throws -> T {
        var mutableRequest = request
        
        if let body = body {
            mutableRequest.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await session.data(for: mutableRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        // Parse rate limit headers
        if let remaining = httpResponse.value(forHTTPHeaderField: "X-RateLimit-Remaining") {
            UsageTracker.shared.updateRemaining(Int(remaining) ?? 0)
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
            
        case 401:
            // Token expired - try refresh
            if let refreshed = try? await AuthManager.shared.refreshToken() {
                if refreshed {
                    // Retry with new token
                    var retryRequest = mutableRequest
                    if let newToken = AuthManager.shared.getToken() {
                        retryRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
                    }
                    let (retryData, retryResponse) = try await session.data(for: retryRequest)
                    guard let retryHTTP = retryResponse as? HTTPURLResponse,
                          (200...299).contains(retryHTTP.statusCode) else {
                        throw APIError.unauthorized
                    }
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    return try decoder.decode(T.self, from: retryData)
                }
            }
            throw APIError.unauthorized
            
        case 429:
            let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let code = errorBody?["code"] as? String
            let message = errorBody?["error"] as? String ?? "Rate limited"
            
            if code == "FREE_LIMIT_REACHED" {
                throw APIError.freeLimitReached(message)
            }
            throw APIError.rateLimited(message)
            
        default:
            let errorBody = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let message = errorBody?["error"] as? String ?? "Unknown error"
            throw APIError.httpError(httpResponse.statusCode, message)
        }
    }
}
