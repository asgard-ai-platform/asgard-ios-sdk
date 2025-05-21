import Foundation

/// Error types for Asgard framework
public enum AsgardError: Error {
    // MARK: - Core Errors
    /// SDK not initialized
    case notInitialized
    /// Invalid API Key
    case invalidApiKey
    /// Invalid service endpoint
    case invalidEndpoint
    /// Invalid bot provider endpoint
    case invalidBotProviderEndpoint
    /// Service error
    case serviceError(String)
    
    // MARK: - Chatbot Errors
    /// Invalid server response
    case invalidResponse
    /// Invalid URL
    case invalidURL
    
    public var localizedDescription: String {
        switch self {
        // Core Errors
        case .notInitialized:
            return "SDK has not been initialized"
        case .invalidApiKey:
            return "Invalid API key provided"
        case .invalidEndpoint:
            return "Invalid service endpoint"
        case .invalidBotProviderEndpoint:
            return "Invalid bot provider endpoint"
        case .serviceError(let message):
            return "Service error: \(message)"
            
        // Chatbot Errors
        case .invalidResponse:
            return "Invalid response from server"
        case .invalidURL:
            return "Invalid URL provided"
        }
    }
} 
