//
//  ContentView.swift
//  TestLib
//
//  Created by INK on 2025/5/16.
//

import SwiftUI
import AsgardCore

struct ContentView: View {
        // Configuration fields
    @State private var apiKey: String = "YOUR-API-KEY"
    @State private var endpoint: String = "YOUR-ENDPOINT-URL"
    @State private var botProviderEndpoint: String = "YOUR-BOT-PROVIDER-ENDPOINT"

    @State private var chatbot: AsgardChatbot?
    @State private var logs: String = ""
    @State private var errorMessage: String?
    @State private var inputMessage: String = ""
    @State private var showChatInterface: Bool = false
    @State private var isLoading: Bool = false

    
    var body: some View {
        VStack(spacing: 0) {
            // Test Button
            Button("Initialize ChatBot") {
                initializeChatBot()
            }
            .padding()
            
            // Error Message
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // Chat Interface
            if showChatInterface {
                VStack(spacing: 0) {
                    // Log Display Area
                    ScrollView {
                        Text(logs)
                            .font(.system(.body, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    
                    // Input Area
                    HStack {
                        TextField("Enter message...", text: $inputMessage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                            .disabled(isLoading)
                        
                        Button(action: sendMessage) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Text("Send")
                            }
                        }
                        .disabled(inputMessage.isEmpty || isLoading)
                        .padding(.trailing)
                    }
                    .padding(.vertical)
                    .background(Color(.systemBackground))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    private func initializeChatBot() {
        print("Initializing ChatBot")
        
        // Clear old logs
        logs = ""
        
        let chatConfig = AsgardChatbotConfig(
            apiKey: apiKey,
            endpoint: endpoint,
            botProviderEndpoint: botProviderEndpoint,
            onExecutionError: { error in
                DispatchQueue.main.async {
                    print("Error occurred: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            },
            transformSsePayload: { raw in
                DispatchQueue.main.async {
                    self.logs = "\(raw)\n\(self.logs)"
                }
            },
            onReset: {
                DispatchQueue.main.async {
                    self.logs = "Received: onReset\n\(self.logs)"
                    self.isLoading = false
                }
            },
            onClose: {
                DispatchQueue.main.async {
                    self.logs = "Received: onClose\n\(self.logs)"
                    self.isLoading = false
                }
            }
        )
        Asgard.setLogLevel(.full)
        chatbot = Asgard.getChatbot(config: chatConfig)
        chatbot?.start()
        
        // Show chat interface
        DispatchQueue.main.async {
            self.showChatInterface = true
        }
    }
    
    private func sendMessage() {
        guard !inputMessage.isEmpty else { return }
        
        isLoading = true
        
        // Send message
        chatbot?.sendMessage(inputMessage)
        
        // Clear input field
        inputMessage = ""
    }
}

#Preview {
    ContentView()
}

