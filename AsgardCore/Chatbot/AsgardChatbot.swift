//
//  AsgardChatbot.swift
//  AsgardCore
//
//  Created by INK on 2025/5/21.
//


import Foundation

public class AsgardChatbot {
    // MARK: - Properties
    private let coreConfig: AsgardChatbotConfig
    private let uiConfig: AsgardChatbotUIConfig?
    private let chatManager: AsgardChatManager
    private var isStarted: Bool = false
    
    // MARK: - Initialization
    init(
        coreConfig: AsgardChatbotConfig,
        uiConfig: AsgardChatbotUIConfig?
    ) {
        self.coreConfig = coreConfig
        self.uiConfig = uiConfig
        self.chatManager = AsgardChatManager(config: coreConfig)
    }
    
    // MARK: - Public Methods
    
    /// Send message
    /// - Parameters:
    ///   - text: Message text
    ///   - action: Action type
    ///   - customMessageId: Custom message ID
    public func sendMessage(_ text: String, action: String = "NONE", customMessageId: String = "") {
        guard isStarted else {
            coreConfig.onExecutionError?(AsgardError.notInitialized)
            return
        }
        chatManager.sendMessage(text, action: action, customMessageId: customMessageId)
    }
    
    /// Start chatbot
    public func start() {
        guard !isStarted else { return }
        isStarted = true
        chatManager.sendMessage("", action: "RESET_CHANNEL",)
    }
    
    /// Close chatbot
    public func closed() {
        guard isStarted else { return }
        chatManager.stop()
        isStarted = false
        coreConfig.onClose?()
    }
    
    /// Reset chatbot
    public func reset() {
        closed()
        start()
        coreConfig.onReset?()
    }
} 
