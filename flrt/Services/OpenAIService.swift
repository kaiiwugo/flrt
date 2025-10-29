//
//  OpenAIService.swift
//  flrt
//
//  OpenAI API implementation
//

import Foundation
import UIKit

class OpenAIService: AIService {
    
    var serviceName: String {
        return "OpenAI GPT-4 Vision"
    }
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4o-mini" // Using gpt-4o-mini for cost-effectiveness, or use "gpt-4o" for full power
    
    init() {
        // Try to load from environment or config
        self.apiKey = APIConfiguration.shared.openAIKey ?? ""
    }
    
    func isConfigured() -> Bool {
        return !apiKey.isEmpty
    }
    
    func processImage(_ request: AIRequest) async throws -> AIResponse {
        print("🔑 API Key configured: \(apiKey.prefix(10))...") // Log first 10 chars only
        print("🌐 Endpoint: \(baseURL)")
        print("🤖 Model: \(model)")
        
        // Convert image to base64
        guard let imageData = request.image.jpegData(compressionQuality: 0.8) else {
            throw AIError.invalidImage
        }
        
        print("📦 Image size: \(imageData.count / 1024)KB")
        
        let base64Image = imageData.base64EncodedString()
        
        // Build request payload
        let payload = buildPayload(
            base64Image: base64Image,
            systemPrompt: request.systemPrompt,
            userPrompt: request.prompt ?? AIConstants.defaultUserPrompt
        )
        
        print("📤 Sending request to OpenAI...")
        
        // Make API request
        let responseData = try await NetworkManager.shared.post(
            url: baseURL,
            headers: [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json"
            ],
            body: payload
        )
        
        print("📥 Received response from OpenAI")
        
        // Parse OpenAI response
        return try parseOpenAIResponse(responseData)
    }
    
    // MARK: - Private Methods
    
    private func buildPayload(base64Image: String, systemPrompt: String, userPrompt: String) -> [String: Any] {
        return [
            "model": model,
            "messages": [
                [
                    "role": "system",
                    "content": systemPrompt
                ],
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": userPrompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)",
                                "detail": "auto"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]
    }
    
    private func parseOpenAIResponse(_ data: Data) throws -> AIResponse {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AIError.invalidResponse
        }
        
        // Extract response text
        guard let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIError.parsingFailed("Could not extract message content")
        }
        
        // Extract usage info
        var tokenUsage: AIResponse.TokenUsage?
        if let usage = json["usage"] as? [String: Any],
           let promptTokens = usage["prompt_tokens"] as? Int,
           let completionTokens = usage["completion_tokens"] as? Int,
           let totalTokens = usage["total_tokens"] as? Int {
            tokenUsage = AIResponse.TokenUsage(
                promptTokens: promptTokens,
                completionTokens: completionTokens,
                totalTokens: totalTokens
            )
        }
        
        let model = json["model"] as? String
        
        return AIResponse(
            rawText: content,
            timestamp: Date(),
            model: model,
            tokenUsage: tokenUsage
        )
    }
}

