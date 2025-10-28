//
//  SharedDataManager.swift
//  flrt
//
//  Shared manager for communication between app and keyboard extension
//

import Foundation
import UIKit

class SharedDataManager {
    static let shared = SharedDataManager()
    
    // App Group identifier - must match entitlements
    private let appGroupIdentifier = "group.com.flrt.shared"
    
    // Keys for UserDefaults
    private let imageDataKey = "sharedImageData"
    private let imageNameKey = "sharedImageName"
    private let responseKey = "sharedResponse"
    private let timestampKey = "sharedTimestamp"
    
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupIdentifier)
    }
    
    private var sharedContainerURL: URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    }
    
    private init() {}
    
    // MARK: - Keyboard Extension Methods
    
    /// Save image from keyboard to shared container
    func saveImageFromKeyboard(_ image: UIImage, name: String) -> Bool {
        guard let imageData = image.jpegData(compressionQuality: 0.8),
              let containerURL = sharedContainerURL else {
            print("Failed to prepare image data or get container URL")
            return false
        }
        
        // Save image to shared container
        let imageURL = containerURL.appendingPathComponent("screenshot.jpg")
        do {
            try imageData.write(to: imageURL)
            print("Image saved to: \(imageURL.path)")
        } catch {
            print("Failed to save image: \(error)")
            return false
        }
        
        // Save metadata to UserDefaults
        sharedDefaults?.set(name, forKey: imageNameKey)
        sharedDefaults?.set(Date().timeIntervalSince1970, forKey: timestampKey)
        sharedDefaults?.removeObject(forKey: responseKey) // Clear old response
        sharedDefaults?.synchronize()
        
        print("Image metadata saved: \(name)")
        return true
    }
    
    /// Get response from main app (called by keyboard)
    func getResponse() -> String? {
        return sharedDefaults?.string(forKey: responseKey)
    }
    
    /// Clear response (after keyboard reads it)
    func clearResponse() {
        sharedDefaults?.removeObject(forKey: responseKey)
        sharedDefaults?.synchronize()
    }
    
    // MARK: - Main App Methods
    
    /// Check if there's a new image to process (called by main app)
    func hasNewImage() -> Bool {
        guard let containerURL = sharedContainerURL else { return false }
        let imageURL = containerURL.appendingPathComponent("screenshot.jpg")
        return FileManager.default.fileExists(atPath: imageURL.path)
    }
    
    /// Get image and name from shared container (called by main app)
    func getImageFromKeyboard() -> (image: UIImage, name: String)? {
        guard let containerURL = sharedContainerURL else {
            print("Failed to get container URL")
            return nil
        }
        
        let imageURL = containerURL.appendingPathComponent("screenshot.jpg")
        
        guard FileManager.default.fileExists(atPath: imageURL.path),
              let imageData = try? Data(contentsOf: imageURL),
              let image = UIImage(data: imageData) else {
            print("Failed to load image from: \(imageURL.path)")
            return nil
        }
        
        let name = sharedDefaults?.string(forKey: imageNameKey) ?? "screenshot.jpg"
        print("Image loaded from shared container: \(name)")
        
        // Delete the image after reading
        try? FileManager.default.removeItem(at: imageURL)
        
        return (image, name)
    }
    
    /// Save response from main app (for keyboard to read)
    func saveResponse(_ response: String) {
        sharedDefaults?.set(response, forKey: responseKey)
        sharedDefaults?.synchronize()
        print("Response saved: \(response)")
    }
    
    /// Get timestamp of last image
    func getLastImageTimestamp() -> Date? {
        guard let timestamp = sharedDefaults?.double(forKey: timestampKey) else {
            return nil
        }
        return Date(timeIntervalSince1970: timestamp)
    }
}

