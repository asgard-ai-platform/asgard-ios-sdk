//
//  AsgardSSEResponse.swift
//  AsgardCore
//
//  Created by INK on 2025/5/21.
//


import Foundation

// Base structure for SSE response
public struct AsgardSSEResponse: Codable {
    public let eventType: AsgardSSEEventType
    public let requestId: String
    public let eventId: String
    public let namespace: String
    public let botProviderName: String
    public let customChannelId: String
    public let fact: AsgardSSEFact
    public var rawString: String = ""
    
    public var conversationState: AsgardConversationState {
        switch eventType {
        case .runInit:
            return .initializing
        case .runDone:
            return .completed
        case .messageStart, .messageDelta, .messageComplete:
            return .inProgress
        }
    }
    
    public init() {
        self.eventType = .messageDelta
        self.requestId = ""
        self.eventId = ""
        self.namespace = ""
        self.botProviderName = ""
        self.customChannelId = ""
        self.fact = AsgardSSEFact()
        self.rawString = ""
    }
    
    // Add CodingKeys to ignore rawString
    private enum CodingKeys: String, CodingKey {
        case eventType
        case requestId
        case eventId
        case namespace
        case botProviderName
        case customChannelId
        case fact
        // rawString is not here, so it will be ignored
    }
}

// SSE event type
public enum AsgardSSEEventType: String, Codable {
    case runInit = "asgard.run.init"
    case runDone = "asgard.run.done"
    case messageStart = "asgard.message.start"
    case messageDelta = "asgard.message.delta"
    case messageComplete = "asgard.message.complete"
}

// Conversation state enum
public enum AsgardConversationState: String, Codable {
    case initializing = "INITIALIZING"
    case inProgress = "IN_PROGRESS"
    case completed = "COMPLETED"
    case error = "ERROR"
}

// Template type enum
public enum AsgardTemplateType: String, Codable {
    case text = "TEXT"
    // Add other types as needed
}

public struct AsgardChatMessage: Codable, Hashable {
    public var text: String?
    public var messageId: String?
    public var replyToCustomMessageId: String?
    public var payload: String?
    public var isDebug: Bool?
    public var idx: Int?
    public var template: AsgardMessageTemplate?
    public var state: AsgardConversationState?
    
    public init() {
        self.text = nil
        self.messageId = nil
        self.replyToCustomMessageId = nil
        self.payload = nil
        self.isDebug = nil
        self.idx = nil
        self.template = nil
        self.state = nil
    }
    
    public var displayText: String {
        return template?.text ?? text ?? ""
    }
    
    public var isComplete: Bool {
        return template != nil
    }
    
    public static func == (lhs: AsgardChatMessage, rhs: AsgardChatMessage) -> Bool {
        return lhs.text == rhs.text &&
               lhs.messageId == rhs.messageId &&
               lhs.replyToCustomMessageId == rhs.replyToCustomMessageId &&
               lhs.payload == rhs.payload &&
               lhs.isDebug == rhs.isDebug &&
               lhs.idx == rhs.idx &&
               lhs.template == rhs.template
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(text)
        hasher.combine(messageId)
        hasher.combine(replyToCustomMessageId)
        hasher.combine(payload)
        hasher.combine(isDebug)
        hasher.combine(idx)
        hasher.combine(template)
    }
}

public struct AsgardErrorInfo: Codable, Hashable {
    public var code: Int?
    public var message: String?
    
    public init() {}
    
    public static func == (lhs: AsgardErrorInfo, rhs: AsgardErrorInfo) -> Bool {
        return lhs.code == rhs.code &&
               lhs.message == rhs.message
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(message)
    }
}

public enum AsgardMessageType: String, Codable, Hashable {
    case `default` = "DEFAULT"
    case delta = "DELTA"
    case complete = "COMPLETE"
    case done = "DONE"
}

struct AsgardChatConfigs: Codable, Hashable {
    struct Data: Codable, Hashable {
        let chatLimit: Int?
    }
    let data: Data?
    let code: Int?
}

// Fact structure
public struct AsgardSSEFact: Codable {
    public let runInit: [String: String]?
    public let runDone: [String: String]?
    public let runError: String?
    public let processStart: String?
    public let processComplete: String?
    public let messageStart: AsgardSSEMessageStart?
    public let messageDelta: AsgardSSEMessageDelta?
    public let messageComplete: AsgardSSEMessageComplete?
    
    public var currentEvent: AsgardSSEEventType? {
        if runInit != nil { return .runInit }
        if runDone != nil { return .runDone }
        if messageStart != nil { return .messageStart }
        if messageDelta != nil { return .messageDelta }
        if messageComplete != nil { return .messageComplete }
        return nil
    }
    
    public init() {
        self.runInit = nil
        self.runDone = nil
        self.runError = nil
        self.processStart = nil
        self.processComplete = nil
        self.messageStart = nil
        self.messageDelta = nil
        self.messageComplete = nil
    }
}

// Message start structure
public struct AsgardSSEMessageStart: Codable {
    public let message: AsgardSSEMessage
}

// Message delta structure
public struct AsgardSSEMessageDelta: Codable {
    public let message: AsgardSSEMessage
}

// Message complete structure
public struct AsgardSSEMessageComplete: Codable {
    public let message: AsgardSSEMessage
}

// Message structure
public struct AsgardSSEMessage: Codable {
    public let messageId: String
    public let replyToCustomMessageId: String?
    public let text: String
    public let payload: String?
    public let isDebug: Bool
    public let idx: Int?
    public let template: AsgardMessageTemplate?
    
    public var isEmpty: Bool {
        return text.isEmpty && template == nil
    }
    
    public var isComplete: Bool {
        return template != nil
    }
    
    public var displayText: String {
        return template?.text ?? text
    }
}

// Template structure
public struct AsgardMessageTemplate: Codable, Hashable {
    public let type: AsgardTemplateType
    public let text: String
    public let payload: String?
    
    public static func == (lhs: AsgardMessageTemplate, rhs: AsgardMessageTemplate) -> Bool {
        return lhs.type == rhs.type &&
               lhs.text == rhs.text &&
               lhs.payload == rhs.payload
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(text)
        hasher.combine(payload)
    }
}

// Conversation manager
public class AsgardConversationManager {
    public static let shared = AsgardConversationManager()
    private init() {}
    
    private var currentState: AsgardConversationState = .initializing
    private var messages: [AsgardChatMessage] = []
    
    public func handleSSEResponse(_ response: AsgardSSEResponse) {
        currentState = response.conversationState
        
        switch response.eventType {
        case .runInit:
            // Handle initialization
            break
        case .runDone:
            // Handle conversation completion
            break
        case .messageStart:
            if let messageStart = response.fact.messageStart {
                // Handle message start
                //let message = messageStart.message

            }
        case .messageDelta:
            if let messageDelta = response.fact.messageDelta {
                // Handle message delta update
                //let message = messageDelta.message

            }
        case .messageComplete:
            if let messageComplete = response.fact.messageComplete {
                // Handle message completion
                //let message = messageComplete.message
            }
        }
    }
    
    public func getCurrentState() -> AsgardConversationState {
        return currentState
    }
    
    public func getMessages() -> [AsgardChatMessage] {
        return messages
    }
}
