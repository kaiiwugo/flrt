//
//  AIModels.swift
//  flrt
//
//  Data models for AI processing pipeline
//

import Foundation
import UIKit

// MARK: - Request Models

/// Request to process an image with AI
struct AIRequest {
    let image: UIImage
    let prompt: String?
    let systemPrompt: String
    let maxSuggestions: Int
    let configuration: PromptConfiguration
    
    init(
        image: UIImage,
        prompt: String? = nil,
        systemPrompt: String? = nil,
        maxSuggestions: Int = 3,
        configuration: PromptConfiguration = PromptConfiguration()
    ) {
        self.image = image
        self.configuration = configuration
        self.maxSuggestions = maxSuggestions
        
        // Build prompts from configuration
        let prompts = PromptTemplate.build(with: configuration)
        self.systemPrompt = systemPrompt ?? prompts.system
        self.prompt = prompt ?? prompts.user
    }
}

// MARK: - Response Models

/// Raw response from AI API
struct AIResponse {
    let rawText: String
    let timestamp: Date
    let model: String?
    let tokenUsage: TokenUsage?
    
    struct TokenUsage {
        let promptTokens: Int
        let completionTokens: Int
        let totalTokens: Int
    }
}

/// Parsed response ready for keyboard display
struct ParsedResponse {
    let suggestions: [MessageSuggestion]
    let originalContext: String?
    let metadata: ResponseMetadata
    
    struct ResponseMetadata {
        let processingTime: TimeInterval
        let confidence: Double?
        let model: String?
    }
}

/// Individual message suggestion for keyboard
struct MessageSuggestion {
    let text: String
    let confidence: Double?
    let category: SuggestionCategory?
    
    enum SuggestionCategory: String {
        case casual = "casual"
        case professional = "professional"
        case funny = "funny"
        case question = "question"
        case statement = "statement"
    }
}

// MARK: - Constants

// MARK: - Constants (Legacy - Use PromptTemplate instead)

enum AIConstants {
    // Kept for backward compatibility
    // New code should use PromptTemplate.build(with: PromptConfiguration())
    static let defaultSystemPrompt = PromptTemplate.default.systemPrompt
    static let defaultUserPrompt = PromptTemplate.default.userPromptTemplate
}

// MARK: - Error Handling

enum AIError: LocalizedError {
    case invalidImage
    case encodingFailed
    case networkError(Error)
    case invalidResponse
    case parsingFailed(String)
    case rateLimitExceeded
    case unauthorized
    case serviceUnavailable
    
    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Failed to process image"
        case .encodingFailed:
            return "Failed to encode image data"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .parsingFailed(let reason):
            return "Failed to parse response: \(reason)"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .unauthorized:
            return "API key is invalid or missing"
        case .serviceUnavailable:
            return "AI service is currently unavailable"
        }
    }
}

