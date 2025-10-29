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
        
        print("📸 Processing image: \(imageName)")
        
        // Simulate processing (in the future, this will call an LLM)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            // For now, just return the filename
            let response = "the file is: \(imageName)"
            
            print("✅ Processed! Response: \(response)")
            
            // Save response for keyboard to read
            SharedDataManager.shared.saveResponse(response)
            
            // Update UI
            self?.lastProcessedImage = imageName
            self?.isProcessing = false
        }
    }
    
    deinit {
        monitorTimer?.invalidate()
        if let observer = screenshotObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

#Preview {
    ContentView()
}
