//
//  AsgardChatManager.swift
//  AsgardCore
//
//  Created by INK on 2025/5/21.
//

import Foundation
import UIKit
internal import LDSwiftEventSource

/// Chat BotManager
/// Responsible for handling communication with the server
/// Uses SSE (Server-Sent Events) for real-time communication
public final class AsgardChatManager {
    private let coreConfig: AsgardChatbotConfig
    private var eventSource: EventSource?
    private var isConnected = false
    
    public init(config: AsgardChatbotConfig) {
        self.coreConfig = config
    }
    
    /// Send message
    /// - Parameters:
    ///   - text: Message text
    ///   - action: Action type
    ///   - customMessageId: Custom message ID
    public func sendMessage(_ text: String, action: String = "NONE", customMessageId: String = "") {
        if text.isEmpty {
            return
        }
        
        setSSEConnection(action: action, customMessageId: customMessageId, text: text)
    }
    
    /// Stop SSE connection
    public func stop() {
        eventSource?.stop()
    }
    
    // MARK: - Private Methods
    
    private func setSSEConnection(action: String, customMessageId: String = "", text: String) {
        guard let url = URL(string: coreConfig.endpoint) else {
            coreConfig.onExecutionError?(AsgardError.invalidEndpoint)
            return
        }
        
        guard coreConfig.apiKey.isEmpty == false else {
            coreConfig.onExecutionError?(AsgardError.invalidApiKey)
            return
        }
        
        let headers = ["X-API-KEY": coreConfig.apiKey,
                      "Content-Type": "application/json"]
        let eventHandler = AsgardEventHandler()
        
        var config = EventSource.Config(handler: eventHandler, url: url)
        config.headers = headers
        config.method = "POST"
        
        let requestBody: [String: Any] = [
            "action": action,
            "customChannelId": coreConfig.customChannelId,
            "customMessageId": customMessageId,
            "text": text
        ]
        
        ALog.info("text: \(text)\ncustom channel id: \(coreConfig.customChannelId)\ncustom message id:\(customMessageId)")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            config.body = jsonData
            eventSource = EventSource(config: config)
            eventSource?.start()
        } catch {
            ALog.error("❌ Failed to serialize request content: \(error.localizedDescription)")
            self.coreConfig.onExecutionError?(error)
        }
        
        eventHandler.onOpenedHandler = {
            ALog.debug("📬 SSE onOpened")
        }
        
        eventHandler.onMessageHandler = { [weak self] eventType, messageEvent in
            ALog.debug("📬 SSE event: \(eventType)")
            
            let jsonString = messageEvent.data
            ALog.debug("📬 SSE message: \(jsonString)")
            
            self?.coreConfig.transformSsePayload?(jsonString)
            
            guard let jsonData = jsonString.data(using: .utf8) else {
                let error = NSError(domain: "AsgardChat", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to Data"])
                ALog.error("❌ Failed to convert JSON string to Data")
                self?.coreConfig.onExecutionError?(error)
                return
            }
            
            do {
                var element = try JSONDecoder().decode(AsgardSSEResponse.self, from: jsonData)
                element.rawString = jsonString
                
                if element.eventType == .runDone {
                    self?.eventSource?.stop()
                }
            } catch {
                ALog.error("❌ JSON decoding failed: \(error.localizedDescription)")
                ALog.error("❌ JSON content: \(jsonString)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        ALog.error("❌ Missing key: \(key.stringValue), context: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        ALog.error("❌ Type mismatch: expected \(type), context: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        ALog.error("❌ Value not found: expected \(type), context: \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        ALog.error("❌ Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        ALog.error("❌ Unknown decoding error")
                    }
                }
                self?.coreConfig.onExecutionError?(error)
            }
        }
        
        eventHandler.onClosedHandler = { [weak self] in
            ALog.debug("📬 SSE onClosed")
            self?.eventSource?.stop()
            self?.coreConfig.onClose?()
        }
        
        eventHandler.onErrorHandler = { [weak self] error in
            ALog.error("📬 SSE error: \(error.localizedDescription)")
            self?.coreConfig.onExecutionError?(error)
        }
    }
}
