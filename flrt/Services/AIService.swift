//
//  AIService.swift
//  flrt
//
//  Protocol and base implementation for AI services
//

import Foundation
import UIKit

// MARK: - AI Service Protocol

protocol AIService {
    /// Process an image and return suggestions
    func processImage(_ request: AIRequest) async throws -> AIResponse
    
    /// Check if service is properly configured
    func isConfigured() -> Bool
    
    /// Get service name
    var serviceName: String { get }
}

// MARK: - AI Service Manager

class AIServiceManager {
    static let shared = AIServiceManager()
    
    private var currentService: AIService
    
    private init() {
        // Default to OpenAI, but can be swapped
        self.currentService = OpenAIService()
    }
    
    /// Set the active AI service
    func setService(_ service: AIService) {
        self.currentService = service
        print("🤖 AI Service changed to: \(service.serviceName)")
    }
    
    /// Process image through current service
    func processImage(_ request: AIRequest) async throws -> ParsedResponse {
        let startTime = Date()
        
        // Check if service is configured
        guard currentService.isConfigured() else {
            throw AIError.unauthorized
        }
        
        // Get raw response from AI
        print("🤖 Processing image with \(currentService.serviceName)...")
        let rawResponse = try await currentService.processImage(request)
        
        // Parse response
        print("🔍 Parsing AI response...")
        let parsedResponse = try ResponseParser.parse(rawResponse, maxSuggestions: request.maxSuggestions)
        
        let processingTime = Date().timeIntervalSince(startTime)
        print("✅ Processing complete in \(String(format: "%.2f", processingTime))s")
        
        // Add metadata
        return ParsedResponse(
            suggestions: parsedResponse.suggestions,
            originalContext: parsedResponse.originalContext,
            metadata: ParsedResponse.ResponseMetadata(
                processingTime: processingTime,
                confidence: nil,
                model: rawResponse.model
            )
        )
    }
    
    /// Get current service
    func getCurrentService() -> AIService {
        return currentService
    }
}

