import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()
    private init() {}

    private let service = Configuration.keychainServiceName

    // MARK: - Save
    @discardableResult
    func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        delete(key: key)

        // Try with app group first, fall back without
        var query = baseQuery(key: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        var status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            // Retry without access group (sideloaded / no entitlement)
            var fallback = baseQueryNoGroup(key: key)
            fallback[kSecValueData as String] = data
            fallback[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
            delete(key: key)
            status = SecItemAdd(fallback as CFDictionary, nil)
        }

        return status == errSecSuccess
    }

    // MARK: - Read
    func read(key: String) -> String? {
        // Try with app group first
        var query = baseQuery(key: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        var status = SecItemCopyMatching(query as CFDictionary, &result)

        if status != errSecSuccess {
            // Retry without access group
            var fallback = baseQueryNoGroup(key: key)
            fallback[kSecReturnData as String] = true
            fallback[kSecMatchLimit as String] = kSecMatchLimitOne
            status = SecItemCopyMatching(fallback as CFDictionary, &result)
        }

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - Delete
    @discardableResult
    func delete(key: String) -> Bool {
        // Delete from both app-group and non-app-group
        let s1 = SecItemDelete(baseQuery(key: key) as CFDictionary)
        let s2 = SecItemDelete(baseQueryNoGroup(key: key) as CFDictionary)
        let ok1 = s1 == errSecSuccess || s1 == errSecItemNotFound
        let ok2 = s2 == errSecSuccess || s2 == errSecItemNotFound
        return ok1 || ok2
    }

    // MARK: - Query Builders
    private func baseQuery(key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecAttrAccessGroup as String: Configuration.appGroupIdentifier
        ]
    }

    private func baseQueryNoGroup(key: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
    }
}
