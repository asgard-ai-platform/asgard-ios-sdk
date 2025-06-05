import SwiftUI

public struct AsgardTheme {
    // MARK: - Color Configuration
    private static var themeConfig: AsgardThemeConfig = AsgardThemeConfig()
    
    // MARK: - Basic Colors
    public static var backgroundColor: Color { themeConfig.chatbot.backgroundColor }
    public static var borderColor: Color { themeConfig.chatbot.borderColor }
    
    // MARK: - Text Colors
    public static var textColor: Color { themeConfig.botMessage.textColor }
    
    // MARK: - Message Bubble Colors
    public static var userMessageBackgroundColor: Color { themeConfig.userMessage.backgroundColor }
    public static var userMessageTextColor: Color { themeConfig.userMessage.textColor }
    public static var botMessageBackgroundColor: Color { themeConfig.botMessage.backgroundColor }
    public static var botMessageTextColor: Color { themeConfig.botMessage.textColor }
    
    // MARK: - Theme Application
    public static func applyTheme(_ config: AsgardThemeConfig) {
        themeConfig = config
        
        // Configure UINavigationBarAppearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(themeConfig.chatbot.backgroundColor)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }
    
    // Restore default appearance
    public static func restoreTheme() {
        let defaultAppearance = UINavigationBarAppearance()
        defaultAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = defaultAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = defaultAppearance
        UINavigationBar.appearance().compactAppearance = defaultAppearance
    }
}

// MARK: - View Extension
public extension View {
    func asgardTheme(_ config: AsgardThemeConfig) -> some View {
        self
            .onAppear {
                AsgardTheme.applyTheme(config)
            }
            .onDisappear {
                AsgardTheme.restoreTheme()
            }
    }
}
