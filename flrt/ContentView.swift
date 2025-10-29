//
//  ContentView.swift
//  flrt
//
//  Created by Kaelin Iwugo on 10/28/25.
//

import SwiftUI
import Photos

struct ContentView: View {
    @StateObject private var imageProcessor = ImageProcessor()
    @StateObject private var photoLibrary = PhotoLibraryManager.shared
    @StateObject private var userPreferences = UserPreferences.shared
    @State private var showingPermissionAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "keyboard")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.system(size: 60))
            
            Text("Flrt Keyboard")
                .font(.title)
                .fontWeight(.bold)
            
            // Photo Access Status
            HStack {
                Image(systemName: photoAccessIcon)
                    .foregroundColor(photoAccessColor)
                Text(photoAccessText)
                    .font(.caption)
                    .foregroundColor(photoAccessColor)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(photoAccessColor.opacity(0.1))
            .cornerRadius(8)
            
            if imageProcessor.isProcessing {
                ProgressView("Processing screenshot...")
                    .padding()
            } else {
                Text("Waiting for screenshots from keyboard...")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let lastProcessedImage = imageProcessor.lastProcessedImage {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Processed:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(lastProcessedImage)
                        .font(.footnote)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            
            Spacer()
            
            Text("Instructions:")
                .font(.headline)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Grant photo library access (below)")
                Text("2. Enable the Flrt keyboard in Settings")
                Text("3. Switch to the Flrt keyboard")
                Text("4. Take a screenshot")
                Text("5. Tap 'Fetch Screenshot' in keyboard")
                Text("6. Watch it process and respond!")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            
            // Request Photo Access Button
            if photoLibrary.authorizationStatus != .authorized {
                Button(action: {
                    Task {
                        await requestPhotoAccess()
                    }
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                        Text("Grant Photo Access")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            imageProcessor.startMonitoring()
            photoLibrary.checkAuthorizationStatus()
            
            // HARDCODED DEFAULTS - TODO: Make these user-configurable in settings
            userPreferences.setDefaults(
                flirtLevel: .flirty,     // Options: .respectful, .flirty, .bold
                age: 25,                 // User's age
                gender: .male,           // User's gender
                targetGender: .female    // Who they're talking to (optional)
            )
            
            print("🎯 User preferences set:")
            print("   Flirt: \(userPreferences.flirtLevel.rawValue)")
            print("   Age: \(userPreferences.userAge)")
            print("   Gender: \(userPreferences.userGender.rawValue)")
        }
        .onDisappear {
            imageProcessor.stopMonitoring()
        }
        .alert("Photo Access Required", isPresented: $showingPermissionAlert) {
            Button("Open Settings", action: openSettings)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Please enable photo library access in Settings to use this feature.")
        }
    }
    
    // MARK: - Computed Properties
    
    private var photoAccessIcon: String {
        switch photoLibrary.authorizationStatus {
        case .authorized, .limited:
            return "checkmark.circle.fill"
        case .denied, .restricted:
            return "xmark.circle.fill"
        case .notDetermined:
            return "questionmark.circle.fill"
        @unknown default:
            return "exclamationmark.circle.fill"
        }
    }
    
    private var photoAccessColor: Color {
        switch photoLibrary.authorizationStatus {
        case .authorized, .limited:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        @unknown default:
            return .gray
        }
    }
    
    private var photoAccessText: String {
        switch photoLibrary.authorizationStatus {
        case .authorized:
            return "Photo Access: Granted"
        case .limited:
            return "Photo Access: Limited"
        case .denied:
            return "Photo Access: Denied"
        case .restricted:
            return "Photo Access: Restricted"
        case .notDetermined:
            return "Photo Access: Not Requested"
        @unknown default:
            return "Photo Access: Unknown"
        }
    }
    
    // MARK: - Methods
    
    private func requestPhotoAccess() async {
        let status = await photoLibrary.requestAuthorization()
        if status == .denied || status == .restricted {
            await MainActor.run {
                showingPermissionAlert = true
            }
        }
    }
    
    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// Image Processor ViewModel
class ImageProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var lastProcessedImage: String?
    
    private var monitorTimer: Timer?
    private var screenshotObserver: NSObjectProtocol?
    private let userPreferences = UserPreferences.shared
    
    func startMonitoring() {
        print("Starting image monitoring...")
        
        // Check immediately
        checkForNewImage()
        
        // Monitor for screenshot notifications
        startScreenshotDetection()
        
        // Then check every 1 second
        monitorTimer?.invalidate()
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForNewImage()
        }
    }
    
    func startScreenshotDetection() {
        // Listen for screenshot notifications
        screenshotObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            print("📸 Screenshot detected by main app!")
            // Give the screenshot a moment to save to photo library
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self?.checkForNewImage()
            }
        }
    }
    
    func stopMonitoring() {
        print("Stopping image monitoring...")
        monitorTimer?.invalidate()
        monitorTimer = nil
        
        // Remove screenshot observer
        if let observer = screenshotObserver {
            NotificationCenter.default.removeObserver(observer)
            screenshotObserver = nil
        }
    }
    
    private func checkForNewImage() {
        guard !isProcessing else { return }
        
        if SharedDataManager.shared.hasNewImage() {
            processNewImage()
        }
    }
    
    func processNewImage() {
        guard let imageData = SharedDataManager.shared.getImageFromKeyboard() else {
            print("Failed to get image from keyboard")
            return
        }
        
        isProcessing = true
        let imageName = imageData.name
        let image = imageData.image
        
        print("📸 Processing image: \(imageName)")
        
        // Process with AI
        Task {
            do {
                // Get current user configuration
                let config = userPreferences.currentConfiguration()
                
                // Create AI request with configuration
                let request = AIRequest(
                    image: image,
                    configuration: config
                )
                
                print("📋 Using configuration:")
                print("   Flirt Level: \(config.flirtLevel.rawValue)")
                print("   Age: \(config.userAge)")
                print("   Gender: \(config.userGender.rawValue)")
                
                // Process through AI service
                let parsedResponse = try await AIServiceManager.shared.processImage(request)
                
                // Convert to keyboard format (JSON string with suggestions)
                let responseJSON = formatResponseForKeyboard(parsedResponse)
                
                print("✅ AI Processing complete!")
                print("   Suggestions: \(parsedResponse.suggestions.count)")
                print("   Context: \(parsedResponse.originalContext ?? "none")")
                
                // Save response for keyboard to read
                await MainActor.run {
                    SharedDataManager.shared.saveResponse(responseJSON)
                    self.lastProcessedImage = imageName
                    self.isProcessing = false
                }
                
            } catch let error as AIError {
                print("❌ AI Error: \(error.errorDescription ?? error.localizedDescription)")
                
                // Send fallback response
                await MainActor.run {
                    let fallbackResponse = createFallbackResponse(error: error)
                    SharedDataManager.shared.saveResponse(fallbackResponse)
                    self.lastProcessedImage = "Error: \(imageName)"
                    self.isProcessing = false
                }
                
            } catch {
                print("❌ Unexpected error: \(error.localizedDescription)")
                
                // Send generic fallback
                await MainActor.run {
                    let fallbackResponse = createGenericFallbackResponse()
                    SharedDataManager.shared.saveResponse(fallbackResponse)
                    self.lastProcessedImage = "Error: \(imageName)"
                    self.isProcessing = false
                }
            }
        }
    }
    
    // MARK: - Response Formatting
    
    private func formatResponseForKeyboard(_ response: ParsedResponse) -> String {
        // Format as JSON for keyboard to parse
        let suggestions = response.suggestions.map { suggestion in
            return [
                "text": suggestion.text,
                "category": suggestion.category?.rawValue ?? "casual"
            ]
        }
        
        let jsonDict: [String: Any] = [
            "suggestions": suggestions,
            "context": response.originalContext ?? "",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        // Convert to JSON string
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict, options: []),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        // Fallback: return plain text
        return response.suggestions.map { $0.text }.joined(separator: "|")
    }
    
    private func createFallbackResponse(error: AIError) -> String {
        let suggestions: [[String: String]]
        
        switch error {
        case .unauthorized:
            suggestions = [
                ["text": "API key not configured", "category": "error"],
                ["text": "Please check app settings", "category": "error"],
                ["text": "Unable to process image", "category": "error"]
            ]
            
        case .rateLimitExceeded:
            suggestions = [
                ["text": "Rate limit reached", "category": "error"],
                ["text": "Please try again later", "category": "error"],
                ["text": "Service temporarily unavailable", "category": "error"]
            ]
            
        default:
            suggestions = [
                ["text": "Processing failed", "category": "error"],
                ["text": "Please try again", "category": "error"],
                ["text": "Unable to analyze image", "category": "error"]
            ]
        }
        
        let jsonDict: [String: Any] = [
            "suggestions": suggestions,
            "context": "Error: \(error.errorDescription ?? "Unknown error")",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "Error|Please try again|Processing failed"
    }
    
    private func createGenericFallbackResponse() -> String {
        let suggestions = [
            ["text": "That's interesting!", "category": "casual"],
            ["text": "Thanks for sharing", "category": "casual"],
            ["text": "What do you think?", "category": "casual"]
        ]
        
        let jsonDict: [String: Any] = [
            "suggestions": suggestions,
            "context": "",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonDict),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "That's interesting!|Thanks for sharing|What do you think?"
    }
    
    deinit {
        monitorTimer?.invalidate()
        if let observer = screenshotObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
