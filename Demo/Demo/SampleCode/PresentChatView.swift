//
//  PresentChatView.swift
//  Demo
//
//  Created by INK on 2025/6/5.
//


import SwiftUI
import AsgardCore
import UIKit

struct PresentChatView: View {
    var body: some View {
        VStack {
            Button("開啟聊天") {
                presentChatbot()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    private func presentChatbot() {
        // 創建 SDK 配置
        let config = AsgardChatbotConfig(
            apiKey: "YOUR-API-KEY",
            endpoint: "YOUR-ENDPOINT-URL",
            botProviderEndpoint: "YOUR-BOT-PROVIDER-ENDPOINT"
        )
        
        // 創建 UI 配置
        let uiConfig = AsgardChatbotUIConfig(
            title: "AI聊天室",
            avatar: nil,
            enableLoadConfigFromService: false,
            debugMode: false,
            botTypingPlaceholder: "正在輸入",
            initMessages: ["歡迎使用","請任意輸入文字"],
            enableSpeechRecognition: true
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            // 使用 Asgard 的 present Chatbot 方法
            Asgard.presentChatbot(
                config: config,
                uiConfig: uiConfig,
                from: rootViewController
            )
        }
    }
}

#Preview {
    PresentChatView()
}
