import Foundation

/// Message type enum
public enum MessageType: String, Codable {
    /// Bot's normal message
    case bot
    /// User's message
    case user
    /// Error message from bot
    case error
}

public struct AsgardChatMessage: Codable, Hashable, Identifiable {
    public var id: String { messageId ?? UUID().uuidString }
    public var messageId: String?
    public var text: String?
    public var replyToCustomMessageId: String?
    public var payload: String?
    public var isDebug: Bool?
    public var idx: Int?
    public var template: AsgardMessageTemplate?
    public var state: AsgardConversationState?
    public let messageType: MessageType
    public let timestamp: Date
    public var eventType: AsgardSSEEventType?
    public var isComplete: Bool
    
    public init(_ messageType: MessageType = .bot) {
        self.messageType = messageType
        self.timestamp = Date()
        self.isComplete = false
    }
    
    public var displayText: String {
        return template?.text ?? text ?? ""
    }
    
    public var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    public static func == (lhs: AsgardChatMessage, rhs: AsgardChatMessage) -> Bool {
        return lhs.text == rhs.text &&
               lhs.messageId == rhs.messageId &&
               lhs.replyToCustomMessageId == rhs.replyToCustomMessageId &&
               lhs.payload == rhs.payload &&
               lhs.isDebug == rhs.isDebug &&
               lhs.idx == rhs.idx &&
               lhs.template == rhs.template &&
               lhs.eventType == rhs.eventType &&
               lhs.isComplete == rhs.isComplete &&
               lhs.messageType == rhs.messageType
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(messageId)
        hasher.combine(replyToCustomMessageId)
        hasher.combine(payload)
        hasher.combine(isDebug)
        hasher.combine(idx)
        hasher.combine(template)
        hasher.combine(eventType)
        hasher.combine(isComplete)
        hasher.combine(messageType)
    }
} 
