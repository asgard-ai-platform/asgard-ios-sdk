//
//  AsgardChatbot.swift
//  AsgardCore
//
//  Created by INK on 2025/5/21.
//


import Foundation
import Combine

public final class AsgardChatbot {
    // MARK: - Properties
    private let config: AsgardChatbotConfig
    private let chatManager: AsgardChatManager
    public let messagePublisher = PassthroughSubject<AsgardChatMessage, Never>()
    public let connectionStatePublisher = CurrentValueSubject<Bool, Never>(false)
    private var isStarted: Bool = false
    
    // MARK: - Initialization
    public init(config: AsgardChatbotConfig) {
        self.config = config
        self.chatManager = AsgardChatManager(config: config)
        
        // Set message receive callback
        self.chatManager.setOnMessageReceived { [weak self] message in
            self?.messagePublisher.send(message)
        }
        
        // Set connection state callback
        self.chatManager.setOnConnectionStateChanged { [weak self] isConnected in
            self?.connectionStatePublisher.send(isConnected)
        }
    }
    
    // MARK: - Public Methods
    
    /// Send message
    /// - Parameters:
    ///   - text: Message text
    ///   - action: Action type
    ///   - customMessageId: Custom message ID
    public func sendMessage(_ text: String, action: String = "NONE", customMessageId: String = "") {
        guard isStarted else {
            config.onExecutionError?(AsgardError.notInitialized)
            return
        }
        
        // Send message to backend
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
        config.onClose?()
    }
    
    /// Reset chatbot
    public func reset() {
        closed()
        start()
        config.onReset?()
    }
} 
