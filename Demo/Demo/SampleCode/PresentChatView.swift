//
//  PresentChatView.swift
//  Demo
//
//  Created by INK on 2025/10/9.
//

import SwiftUI
import AsgardCore
import UIKit

struct PresentChatView: View {
    // Configuration fields
    @State private var apiKey: String = "YOUR-API-KEY"
    @State private var botProviderEndpoint: String = "YOUR-BOT-PROVIDER-ENDPOINT"
    
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
        // 基本資訊
        let config = AsgardConfig(
            apiKey: apiKey,
            botProviderEndpoint: botProviderEndpoint,
            customChannelId: "1",
            isShowDebugLogs: true,
        )
        
        /*  語音設定（選項）
            想開啟語音功能，除了設定 speechRecognitionConfig
            也必須至 plist 加入語音相關權限
            不使用可請直接忽略
        */
        let speechRecognitionConfig = AsgardSpeechConfig(
            text: AsgardSpeechConfig.Text(
                startSpeaking: "請開始說話",
                listening: "正在聆聽...",
                noSpeechDetected: "聽不太清楚\n\n請點擊下方麥克風圖示，\n再試一次。",
                micPermissionDenied: "您未允許使用麥克風權限，\n無法使用此功能。\n\n請開啟手機的系統設定，\n打開麥克風的允許權限。",
                speechPermissionDenied: "您未允許使用語音辨識權限，\n無法使用此功能。\n\n請開啟手機的系統設定，\n打開語音辨識的允許權限。",
                deviceNotSupported: "此裝置不支援語音辨識",
                requestPermission: "請允許使用語音辨識",
                unknownError: "未知錯誤"
            ), locale: Locale(identifier: "zh-TW"))
        
        // UI 畫面設定
        let uiConfig = AsgardUIConfig(
            inputPlaceholder: "請輸入訊息...",
            connectionErrorMessage: "網路連線異常，請檢查您的網路設定，或是稍後再試。",
            speechRecognition: speechRecognitionConfig,
            onUIReset: nil,
            onUIClose: nil,
            onActionURI: { url in
                // 網址事件
                print("onAction URI: \(url.absoluteString)")
            },
            onActionEMIT: { event, payload in
                // EMIT 事件
                print("onAction EMIT event: \(event)")
                if let payload = payload {
                    print("payload: \(payload)")
                }
            }
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

//#Preview {
//    PresentChatView()
//}
