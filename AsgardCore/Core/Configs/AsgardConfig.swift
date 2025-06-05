import Foundation
import UIKit
import SwiftUI

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

    /// Enable Speech Recognition
    public var enableSpeechRecognition: Bool
    
    /// UI Reset Callback
    public var onUIReset: (() -> Void)?
    
    /// UI Close Callback
    public var onUIClose: (() -> Void)?
    
    /// Theme Configuration
    public let theme: AsgardThemeConfig
    
    public init(
        title: String = "Chatbot",
        avatar: String? = nil,
        enableLoadConfigFromService: Bool = false,
        debugMode: Bool = false,
        botTypingPlaceholder: String = "Bot is typing",
        initMessages: [String] = [],
        enableSpeechRecognition: Bool = false,
        onUIReset: (() -> Void)? = nil,
        onUIClose: (() -> Void)? = nil,
        theme: AsgardThemeConfig = AsgardThemeConfig()
    ) {
        self.title = title
        self.avatar = avatar
        self.enableLoadConfigFromService = enableLoadConfigFromService
        self.debugMode = debugMode
        self.botTypingPlaceholder = botTypingPlaceholder
        self.initMessages = initMessages
        self.enableSpeechRecognition = enableSpeechRecognition
        self.onUIReset = onUIReset
        self.onUIClose = onUIClose
        self.theme = theme
    }
}

/// Theme Configuration Structure
public struct AsgardThemeConfig {
    /// Overall Chatbot Configuration
    public let chatbot: ChatbotStyle
    
    /// Bot Message Style
    public let botMessage: MessageStyle
    
    /// User Message Style
    public let userMessage: MessageStyle
    
    public init(
        chatbot: ChatbotStyle = ChatbotStyle(
            backgroundColor: Color(hex: "1F1F1F"),
            borderColor: Color(hex: "1F1F1F")
        ),
        botMessage: MessageStyle = MessageStyle(
            backgroundColor: Color(hex: "585858"),
            textColor: Color(hex: "FFFFFF")
        ),
        userMessage: MessageStyle = MessageStyle(
            backgroundColor: Color(hex: "4767EB"),
            textColor: Color(hex: "FFFFFF")
        )
    ) {
        self.chatbot = chatbot
        self.botMessage = botMessage
        self.userMessage = userMessage
    }
}

/// Overall Chatbot Style
public struct ChatbotStyle {
    /// Background Color
    public let backgroundColor: Color
    
    /// Border Color
    public let borderColor: Color
    
    public init(
        backgroundColor: Color = Color(.systemBackground),
        borderColor: Color = Color(.systemGray4)
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
    }
}

/// Message Style
public struct MessageStyle {
    /// Background Color
    public let backgroundColor: Color
    
    /// Text Color
    public let textColor: Color
    
    public init(
        backgroundColor: Color,
        textColor: Color
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}
