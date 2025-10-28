//
//  flrtApp.swift
//  flrt
//
//  Created by Kaelin Iwugo on 10/28/25.
//

import SwiftUI

@main
struct flrtApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleURL(url)
                }
        }
    }
    
    private func handleURL(_ url: URL) {
        print("🔗 App opened with URL: \(url)")
        
        if url.scheme == "flrt" && url.host == "process-screenshot" {
            print("📸 Processing screenshot request received")
            // The ContentView's monitoring will automatically pick up the new image
        }
    }
}
