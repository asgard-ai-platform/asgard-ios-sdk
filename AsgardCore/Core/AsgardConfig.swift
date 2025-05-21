import Foundation
import UIKit

public struct AsgardChatbotConfig {
    /// API Key
    public let apiKey: String
    
    /// API Endpoint
    public let endpoint: String
    
    /// Bot Provider Endpoint
    public let botProviderEndpoint: String
    
    /// Custom Channel ID
    public let customChannelId: String
    
    /// Execution Error Callback
    public var onExecutionError: ((Error) -> Void)?
    
    /// SSE Payload Transform
    public var transformSsePayload: ((String) -> Void)?
    
    /// Reset Callback
    public var onReset: (() -> Void)?
    
    /// Close Callback
    public var onClose: (() -> Void)?
    
    public init(
        apiKey: String,
        endpoint: String,
        botProviderEndpoint: String,
        customChannelId: String? = nil,
        onExecutionError: ((Error) -> Void)? = nil,
        transformSsePayload: ((String) -> Void)? = nil,
        onReset: (() -> Void)? = nil,
        onClose: (() -> Void)? = nil
    ) {
        self.apiKey = apiKey
        self.endpoint = endpoint
        self.botProviderEndpoint = botProviderEndpoint
        self.customChannelId = customChannelId ?? UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        self.onExecutionError = onExecutionError
        self.transformSsePayload = transformSsePayload
        self.onReset = onReset
        self.onClose = onClose
    }
}

public struct AsgardChatbotUIConfig {
    /// Title
    public let title: String
    
    /// Avatar URL
    public let avatar: String?
    
    /// Enable Load Config From Service
    public let enableLoadConfigFromService: Bool
    
    /// Debug Mode
    public let debugMode: Bool
    
    /// Bot Typing Placeholder
    public let botTypingPlaceholder: String
    
    /// Initial Messages JSON Template
    public let initMessages: [String]
    
    /// UI Reset Callback
    public var onUIReset: (() -> Void)?
    
    /// UI Close Callback
    public var onUIClose: (() -> Void)?
    
    public init(
        title: String,
        avatar: String? = nil,
        enableLoadConfigFromService: Bool = false,
        debugMode: Bool = false,
        botTypingPlaceholder: String = "Bot is typing...",
        initMessages: [String] = [],
        onUIReset: (() -> Void)? = nil,
        onUIClose: (() -> Void)? = nil
    ) {
        self.title = title
        self.avatar = avatar
        self.enableLoadConfigFromService = enableLoadConfigFromService
        self.debugMode = debugMode
        self.botTypingPlaceholder = botTypingPlaceholder
        self.initMessages = initMessages
        self.onUIReset = onUIReset
        self.onUIClose = onUIClose
    }
}
