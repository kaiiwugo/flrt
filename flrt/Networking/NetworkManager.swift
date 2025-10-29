//
//  NetworkManager.swift
//  flrt
//
//  Handles all network requests
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        config.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - POST Request
    
    func post(url: String, headers: [String: String], body: [String: Any]) async throws -> Data {
        guard let url = URL(string: url) else {
            throw AIError.invalidResponse
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            throw AIError.encodingFailed
        }
        
        // Make request
        do {
            let (data, response) = try await session.data(for: request)
            
            // Check HTTP status
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIError.invalidResponse
            }
            
            // Log response for debugging
            print("📡 HTTP Status: \(httpResponse.statusCode)")
            
            switch httpResponse.statusCode {
            case 200...299:
                return data
                
            case 401:
                // Try to get error details
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorDict["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    print("❌ Auth Error: \(message)")
                }
                throw AIError.unauthorized
                
            case 429:
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorDict["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    print("❌ Rate Limit: \(message)")
                }
                throw AIError.rateLimitExceeded
                
            case 500...599:
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorDict["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    print("❌ Server Error: \(message)")
                }
                throw AIError.serviceUnavailable
                
            default:
                // Try to extract error message from response
                if let errorDict = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorDict["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    print("❌ API Error (\(httpResponse.statusCode)): \(message)")
                    throw AIError.parsingFailed(message)
                }
                print("❌ Unknown Error: Status \(httpResponse.statusCode)")
                throw AIError.invalidResponse
            }
            
        } catch let error as AIError {
            throw error
        } catch {
            throw AIError.networkError(error)
        }
    }
}

