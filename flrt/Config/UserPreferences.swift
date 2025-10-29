//
//  UserPreferences.swift
//  flrt
//
//  Manages user preferences and configuration
//

import Foundation

class UserPreferences: ObservableObject {
    static let shared = UserPreferences()
    
    // MARK: - Published Properties
    
    @Published var flirtLevel: FlirtLevel {
        didSet {
            saveFlirtLevel()
        }
    }
    
    @Published var userAge: Int {
        didSet {
            saveUserAge()
        }
    }
    
    @Published var userGender: Gender {
        didSet {
            saveUserGender()
        }
    }
    
    @Published var targetGender: Gender? {
        didSet {
            saveTargetGender()
        }
    }
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let flirtLevel = "userFlirtLevel"
        static let userAge = "userAge"
        static let userGender = "userGender"
        static let targetGender = "targetGender"
    }
    
    // MARK: - Initialization
    
    private init() {
        // Load saved preferences or use defaults
        if let savedFlirtLevel = UserDefaults.standard.string(forKey: Keys.flirtLevel),
           let level = FlirtLevel(rawValue: savedFlirtLevel) {
            self.flirtLevel = level
        } else {
            self.flirtLevel = .flirty  // Default: Flirty (middle ground)
        }
        
        let savedAge = UserDefaults.standard.integer(forKey: Keys.userAge)
        self.userAge = savedAge > 0 ? savedAge : 25  // Default: 25 (target demographic)
        
        if let savedGender = UserDefaults.standard.string(forKey: Keys.userGender),
           let gender = Gender(rawValue: savedGender) {
            self.userGender = gender
        } else {
            self.userGender = .male  // Default: Male (can be changed)
        }
        
        if let savedTargetGender = UserDefaults.standard.string(forKey: Keys.targetGender),
           let gender = Gender(rawValue: savedTargetGender) {
            self.targetGender = gender
        } else {
            self.targetGender = .female  // Default: Female (can be changed)
        }
    }
    
    // MARK: - Save Methods
    
    private func saveFlirtLevel() {
        UserDefaults.standard.set(flirtLevel.rawValue, forKey: Keys.flirtLevel)
    }
    
    private func saveUserAge() {
        UserDefaults.standard.set(userAge, forKey: Keys.userAge)
    }
    
    private func saveUserGender() {
        UserDefaults.standard.set(userGender.rawValue, forKey: Keys.userGender)
    }
    
    private func saveTargetGender() {
        if let gender = targetGender {
            UserDefaults.standard.set(gender.rawValue, forKey: Keys.targetGender)
        } else {
            UserDefaults.standard.removeObject(forKey: Keys.targetGender)
        }
    }
    
    // MARK: - Prompt Configuration
    
    /// Generate a PromptConfiguration from current preferences
    func currentConfiguration() -> PromptConfiguration {
        return PromptConfiguration(
            flirtLevel: flirtLevel,
            userAge: userAge,
            userGender: userGender,
            targetGender: targetGender
        )
    }
    
    // MARK: - Quick Setters (for testing/hardcoding)
    
    func setDefaults(
        flirtLevel: FlirtLevel = .flirty,
        age: Int = 25,
        gender: Gender = .preferNotToSay,
        targetGender: Gender? = nil
    ) {
        self.flirtLevel = flirtLevel
        self.userAge = age
        self.userGender = gender
        self.targetGender = targetGender
    }
    
    // MARK: - Reset
    
    func resetToDefaults() {
        flirtLevel = .flirty
        userAge = 25
        userGender = .preferNotToSay
        targetGender = nil
    }
}

