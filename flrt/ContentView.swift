//
//  ContentView.swift
//  flrt
//
//  Created by Kaelin Iwugo on 10/28/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var imageProcessor = ImageProcessor()
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "keyboard")
                .imageScale(.large)
                .foregroundStyle(.tint)
                .font(.system(size: 60))
            
            Text("Flrt Keyboard")
                .font(.title)
                .fontWeight(.bold)
            
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
                Text("1. Enable the Flrt keyboard in Settings")
                Text("2. Switch to the Flrt keyboard")
                Text("3. Take a screenshot")
                Text("4. Drag the thumbnail to the keyboard")
                Text("5. Watch it process and respond!")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding()
            
            Spacer()
        }
        .padding()
        .onAppear {
            imageProcessor.startMonitoring()
        }
        .onDisappear {
            imageProcessor.stopMonitoring()
        }
    }
}

// Image Processor ViewModel
class ImageProcessor: ObservableObject {
    @Published var isProcessing = false
    @Published var lastProcessedImage: String?
    
    private var monitorTimer: Timer?
    
    func startMonitoring() {
        print("Starting image monitoring...")
        
        // Check immediately
        checkForNewImage()
        
        // Then check every 1 second
        monitorTimer?.invalidate()
        monitorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkForNewImage()
        }
    }
    
    func stopMonitoring() {
        print("Stopping image monitoring...")
        monitorTimer?.invalidate()
        monitorTimer = nil
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
    }
}

#Preview {
    ContentView()
}
