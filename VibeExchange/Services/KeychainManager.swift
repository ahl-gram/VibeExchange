import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    private let serviceName = "com.vibecode.VibeExchange"
    
    // MARK: - Public Methods
    
    func save(key: String, data: Data) -> Bool {
        // Delete any existing item first
        delete(key: key)
        
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ] as [String: Any]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func load(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }
    
    func delete(key: String) -> Bool {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ] as [String: Any]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    // MARK: - Convenience Methods
    
    func saveString(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        return save(key: key, data: data)
    }
    
    func loadString(key: String) -> String? {
        guard let data = load(key: key) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

// MARK: - Configuration Manager

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {}
    
    private lazy var configPlist: [String: Any]? = {
        guard let path = Bundle.main.path(forResource: "Configuration", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            print("Warning: Configuration.plist not found")
            return nil
        }
        return plist
    }()
    
    func getAPIKey() -> String? {
        // First, try to get from Keychain
        let keyIdentifier = getKeyIdentifier()
        if let cachedKey = KeychainManager.shared.loadString(key: keyIdentifier) {
            return cachedKey
        }
        
        // If not in Keychain, decrypt from plist and store in Keychain
        guard let encryptedKey = getEncryptedKey() else {
            print("Error: Could not retrieve encrypted API key from Configuration.plist")
            return nil
        }
        
        // Simple base64 decoding (in production, use proper encryption)
        guard let decodedData = Data(base64Encoded: encryptedKey),
              let decryptedKey = String(data: decodedData, encoding: .utf8) else {
            print("Error: Could not decrypt API key")
            return nil
        }
        
        // Store in Keychain for future use
        _ = KeychainManager.shared.saveString(key: keyIdentifier, value: decryptedKey)
        
        return decryptedKey
    }
    
    func getBaseURL() -> String? {
        guard let config = configPlist,
              let api = config["API"] as? [String: Any],
              let exchangeAPI = api["ExchangeRateAPI"] as? [String: Any],
              let baseURL = exchangeAPI["BaseURL"] as? String else {
            return nil
        }
        return baseURL
    }
    
    private func getKeyIdentifier() -> String {
        guard let config = configPlist,
              let api = config["API"] as? [String: Any],
              let exchangeAPI = api["ExchangeRateAPI"] as? [String: Any],
              let keyIdentifier = exchangeAPI["KeyIdentifier"] as? String else {
            return "exchange_rate_api_key" // fallback
        }
        return keyIdentifier
    }
    
    private func getEncryptedKey() -> String? {
        guard let config = configPlist,
              let api = config["API"] as? [String: Any],
              let exchangeAPI = api["ExchangeRateAPI"] as? [String: Any],
              let encryptedKey = exchangeAPI["EncryptedKey"] as? String else {
            return nil
        }
        return encryptedKey
    }
} 