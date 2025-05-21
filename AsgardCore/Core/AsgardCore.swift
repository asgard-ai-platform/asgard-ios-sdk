//
//  AsgardCore.swift
//  AsgardCore
//
//  Created by INK on 2025/4/30.
//

import Foundation

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
    
    /// Create a new chatbot instance
    /// - Parameters:
    ///   - config: Chatbot configuration
    ///   - uiConfig: Optional UI configuration
    /// - Returns: Chatbot instance
    public static func getChatbot(
        config: AsgardChatbotConfig,
        uiConfig: AsgardChatbotUIConfig? = nil
    ) -> AsgardChatbot {
        return AsgardChatbot(coreConfig: config, uiConfig: uiConfig)
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

