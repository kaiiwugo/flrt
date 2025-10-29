//
//  APIConfiguration.swift
//  flrt
//
//  API keys and configuration management
//

import Foundation

class APIConfiguration {
    static let shared = APIConfiguration()
    
    private init() {
        loadConfiguration()
    }
    
    // MARK: - API Keys
    
    private(set) var openAIKey: String?
    
    // MARK: - Configuration Loading
    
    private func loadConfiguration() {
        // Try to load from Info.plist
        if let key = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String,
           !key.isEmpty && key != "YOUR_API_KEY_HERE" {
            openAIKey = key
            print("✅ OpenAI API key loaded from Info.plist")
            return
        }
        
        // Try to load from environment variable (for development)
        if let key = ProcessInfo.processInfo.environment["OPENAI_API_KEY"],
           !key.isEmpty {
            openAIKey = key
            print("✅ OpenAI API key loaded from environment")
            return
        }
        
        // Try to load from keychain (for secure storage)
        if let key = KeychainManager.shared.getAPIKey(for: .openAI) {
            openAIKey = key
            print("✅ OpenAI API key loaded from keychain")
            return
        }
        
        print("⚠️ No OpenAI API key found. Please configure in Settings.")
    }
    
    // MARK: - Configuration Management
    
    func setOpenAIKey(_ key: String) {
        self.openAIKey = key
        KeychainManager.shared.saveAPIKey(key, for: .openAI)
        print("✅ OpenAI API key saved")
    }
    
    func clearOpenAIKey() {
        self.openAIKey = nil
        KeychainManager.shared.deleteAPIKey(for: .openAI)
        print("🗑️ OpenAI API key cleared")
    }
    
    func hasOpenAIKey() -> Bool {
        return openAIKey != nil && !openAIKey!.isEmpty
    }
}

// MARK: - Keychain Manager

class KeychainManager {
    static let shared = KeychainManager()
    
    private init() {}
    
    enum APIService: String {
        case openAI = "com.flrt.openai"
    }
    
    func saveAPIKey(_ key: String, for service: APIService) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.rawValue,
            kSecValueData as String: key.data(using: .utf8)!
        ]
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func getAPIKey(for service: APIService) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.rawValue,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    func deleteAPIKey(for service: APIService) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service.rawValue
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}

