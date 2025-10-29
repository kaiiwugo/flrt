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
    
    init(
        image: UIImage,
        prompt: String? = nil,
        systemPrompt: String = AIConstants.defaultSystemPrompt,
        maxSuggestions: Int = 3
    ) {
        self.image = image
        self.prompt = prompt
        self.systemPrompt = systemPrompt
        self.maxSuggestions = maxSuggestions
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

enum AIConstants {
    static let defaultSystemPrompt = """
    You are a helpful assistant that analyzes screenshots and suggests 3 appropriate text message responses.
    
    Guidelines:
    - Analyze the context of the screenshot
    - Generate 3 diverse response options
    - Keep responses concise and natural (like text messages)
    - Make responses relevant to what's shown in the image
    - Vary the tone: one casual, one thoughtful, one engaging
    - Each response should be 1-2 sentences max
    
    Format your response as JSON:
    {
        "context": "brief description of what you see",
        "suggestions": [
            {"text": "first response", "tone": "casual"},
            {"text": "second response", "tone": "thoughtful"},
            {"text": "third response", "tone": "engaging"}
        ]
    }
    """
    
    static let defaultUserPrompt = "Analyze this screenshot and suggest 3 appropriate text message responses."
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

