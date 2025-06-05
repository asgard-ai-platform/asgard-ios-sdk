//
//  AsgardCore.swift
//  AsgardCore
//
//  Created by INK on 2025/4/30.
//

import Foundation
import UIKit

public final class Asgard {
    // MARK: - Properties
    private static let manager = AsgardManager.shared
    
    // MARK: - Public Methods
    
    /// Set log level
    /// - Parameter level: Log display level
    public static func setLogLevel(_ level: ALogDisplayLevel) {
        manager.setLogLevel(level)
    }
    
    /// Get SDK version
    public static func getVersion() -> String {
        manager.getVersion()
    }
    
    /// Create a new chatbot instance without UI
    /// - Parameter config: Chatbot configuration
    /// - Returns: Chatbot instance
    public static func getChatbot(config: AsgardChatbotConfig) -> AsgardChatbot {
        return AsgardChatbot(config: config)
    }
    
    /// Push chatbot to navigation stack
    /// - Parameters:
    ///   - config: Chatbot configuration
    ///   - uiConfig: Chatbot UI configuration
    ///   - viewController: Source view controller
    public static func pushChatbot(
        config: AsgardChatbotConfig,
        uiConfig: AsgardChatbotUIConfig,
        from viewController: UIViewController
    ) {
        let chatbot = AsgardChatbot(config: config)
        let viewModel = AsgardChatbotViewModel(chatbot: chatbot, uiConfig: uiConfig)
        let chatbotVC = AsgardChatbotVC(viewModel: viewModel, isModal: false)
        viewController.navigationController?.pushViewController(chatbotVC, animated: true)
    }
    
    /// Present chatbot modally
    /// - Parameters:
    ///   - config: Chatbot configuration
    ///   - uiConfig: Chatbot UI configuration
    ///   - viewController: Source view controller
    public static func presentChatbot(
        config: AsgardChatbotConfig,
        uiConfig: AsgardChatbotUIConfig,
        from viewController: UIViewController
    ) {
        let chatbot = AsgardChatbot(config: config)
        let viewModel = AsgardChatbotViewModel(chatbot: chatbot, uiConfig: uiConfig)
        let chatbotVC = AsgardChatbotVC(viewModel: viewModel, isModal: true)
        let nav = UINavigationController(rootViewController: chatbotVC)
        nav.modalPresentationStyle = .fullScreen
        chatbotVC.modalPresentationStyle = .fullScreen
        viewController.present(nav, animated: true)
    }
}

public final class AsgardManager {
    public static let shared = AsgardManager()

    private init() {}
    
    /// Set log level
    /// - Parameter level: Log display level
    public func setLogLevel(_ level: ALogDisplayLevel) {
        ALog.displayLevel = level
    }
    
    /// Get SDK version number
    /// - Returns: SDK version string
    public func getVersion() -> String {
        if let infoDictionary = Bundle(for: type(of: self)).infoDictionary,
           let version = infoDictionary["CFBundleShortVersionString"] as? String {
            return version
        }
        return "1.0.0" // Default version number
    }
}

