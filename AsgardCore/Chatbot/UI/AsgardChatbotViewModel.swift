import Foundation
import Combine

public class AsgardChatbotViewModel: ObservableObject {
    @Published var messages: [AsgardCore.AsgardChatMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var isTyping: Bool = false
    
    public let chatbot: AsgardChatbot
    public let uiConfig: AsgardChatbotUIConfig
    private var cancellables = Set<AnyCancellable>()
    private var currentMessageId: String?
    private var currentMessageText: String = ""
    
    public init(chatbot: AsgardChatbot, uiConfig: AsgardChatbotUIConfig) {
        self.chatbot = chatbot
        self.uiConfig = uiConfig
        setupSubscriptions()
        
        // Add initial messages
        for message in uiConfig.initMessages {
            var chatMessage = AsgardChatMessage()
            chatMessage.text = message
            chatMessage.messageId = UUID().uuidString
            chatMessage.isComplete = true
            self.messages.append(chatMessage)
        }
    }
    
    private func setupSubscriptions() {
        // Subscribe to chatbot message updates
        chatbot.messagePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.handleMessage(message)
            }
            .store(in: &cancellables)
            
        // Monitor SSE connection state
        chatbot.connectionStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isConnected in
                self?.isLoading = isConnected
            }
            .store(in: &cancellables)
    }
    
    private func handleMessage(_ message: AsgardCore.AsgardChatMessage) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // If it's an error message, add it directly and return
            if message.messageType == .error {
                self.messages.append(message)
                self.isTyping = false
                return
            }
            
            switch message.eventType {
            case .messageStart:
                self.currentMessageId = message.messageId
                self.currentMessageText = message.text ?? ""
                if !self.currentMessageText.isEmpty {
                    self.messages.append(message)
                }
                self.isTyping = true
            case .messageDelta:
                if let text = message.text, !text.isEmpty {
                    // Find the last incomplete bot bubble
                    if let index = self.messages.lastIndex(where: { $0.messageType == .bot && !$0.isComplete }) {
                        self.currentMessageText += text
                        self.messages[index].text = self.currentMessageText
                    } else {
                        // Fallback: create new if not found
                        self.currentMessageId = message.messageId
                        self.currentMessageText = text
                        self.messages.append(message)
                    }
                }
            case .messageComplete:
                if let index = self.messages.lastIndex(where: { $0.messageType == .bot && !$0.isComplete }) {
                    self.messages[index].text = message.text ?? self.currentMessageText
                    self.messages[index].isComplete = true
                }
                self.currentMessageId = nil
                self.currentMessageText = ""
                self.isTyping = false
            default:
                break
            }
        }
    }
    
    public func sendMessage() async {
        guard !inputText.isEmpty else { return }
        
        // Save message content to send
        let messageToSend = inputText
        
        // Create user message
        let userMessage = {
            var message = AsgardChatMessage(.user)
            message.text = messageToSend
            message.messageId = UUID().uuidString
            return message
        }()
        
        await MainActor.run {
            messages.append(userMessage)
            inputText = ""
            isLoading = true  // Set loading state immediately
        }
        
        // Send message using chatbot
        chatbot.sendMessage(messageToSend)
    }
    
    public func reset() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.chatbot.reset()
            self.messages.removeAll()
            self.inputText = ""
            self.isTyping = false
            self.isLoading = false
            self.uiConfig.onUIReset?()
        }
    }
    
    public func close() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.chatbot.closed()
            self.uiConfig.onUIClose?()
        }
    }
} 
