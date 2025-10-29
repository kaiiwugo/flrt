//
//  ResponseParser.swift
//  flrt
//
//  Parses AI responses into keyboard-ready format
//

import Foundation

class ResponseParser {
    
    /// Parse AI response into structured suggestions
    static func parse(_ response: AIResponse, maxSuggestions: Int = 3) throws -> ParsedResponse {
        let rawText = response.rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to parse as JSON first (preferred format)
        if let jsonResponse = tryParseJSON(rawText) {
            return jsonResponse
        }
        
        // Fallback: Parse as plain text
        return parsePlainText(rawText, maxSuggestions: maxSuggestions)
    }
    
    // MARK: - JSON Parsing
    
    private static func tryParseJSON(_ text: String) -> ParsedResponse? {
        // Extract JSON if it's wrapped in markdown code blocks
        let cleanedText = text
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let data = cleanedText.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        // Extract context
        let context = json["context"] as? String
        
        // Extract suggestions
        guard let suggestionsArray = json["suggestions"] as? [[String: Any]] else {
            return nil
        }
        
        let suggestions: [MessageSuggestion] = suggestionsArray.compactMap { dict in
            guard let text = dict["text"] as? String else { return nil }
            
            let tone = dict["tone"] as? String
            let category = tone.flatMap { MessageSuggestion.SuggestionCategory(rawValue: $0) }
            
            return MessageSuggestion(
                text: text,
                confidence: nil,
                category: category
            )
        }
        
        guard !suggestions.isEmpty else { return nil }
        
        return ParsedResponse(
            suggestions: suggestions,
            originalContext: context,
            metadata: ParsedResponse.ResponseMetadata(
                processingTime: 0,
                confidence: nil,
                model: nil
            )
        )
    }
    
    // MARK: - Plain Text Parsing
    
    private static func parsePlainText(_ text: String, maxSuggestions: Int) -> ParsedResponse {
        // Split by common delimiters
        var suggestions: [String] = []
        
        // Try numbered list (1., 2., 3.)
        let numberedPattern = #"^\d+[\.\)]\s*(.+)$"#
        let numberedRegex = try? NSRegularExpression(pattern: numberedPattern, options: .anchorsMatchLines)
        let nsText = text as NSString
        
        if let regex = numberedRegex {
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
            suggestions = matches.compactMap { match in
                guard match.numberOfRanges > 1 else { return nil }
                let range = match.range(at: 1)
                return nsText.substring(with: range).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // Fallback: split by newlines
        if suggestions.isEmpty {
            suggestions = text.components(separatedBy: .newlines)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty && $0.count > 3 }
        }
        
        // Fallback: split by sentence
        if suggestions.isEmpty {
            suggestions = text.components(separatedBy: ". ")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
        }
        
        // Ensure we have at least one suggestion
        if suggestions.isEmpty {
            suggestions = [text]
        }
        
        // Limit to max suggestions
        suggestions = Array(suggestions.prefix(maxSuggestions))
        
        // Convert to MessageSuggestion objects
        let messageSuggestions = suggestions.map { text in
            MessageSuggestion(text: text, confidence: nil, category: nil)
        }
        
        // Pad with fallback suggestions if needed
        let paddedSuggestions = padSuggestions(messageSuggestions, targetCount: maxSuggestions)
        
        return ParsedResponse(
            suggestions: paddedSuggestions,
            originalContext: nil,
            metadata: ParsedResponse.ResponseMetadata(
                processingTime: 0,
                confidence: nil,
                model: nil
            )
        )
    }
    
    // MARK: - Helpers
    
    private static func padSuggestions(_ suggestions: [MessageSuggestion], targetCount: Int) -> [MessageSuggestion] {
        var result = suggestions
        
        // Add fallback suggestions if we don't have enough
        let fallbacks = [
            "That's interesting!",
            "Thanks for sharing",
            "What do you think?"
        ]
        
        while result.count < targetCount {
            let fallbackText = fallbacks[result.count % fallbacks.count]
            result.append(MessageSuggestion(text: fallbackText, confidence: nil, category: .casual))
        }
        
        return result
    }
}

