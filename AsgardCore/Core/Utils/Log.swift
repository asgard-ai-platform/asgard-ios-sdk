import Foundation

/// Log type
@objc public enum ALogType: Int {
    case error
    case warning
    case info
    case debug
}

/// Log display level
@objc public enum ALogDisplayLevel: Int {
    case none    // Only show errors
    case normal  // Show error, warning, info
    case full    // Show all logs
}

/// Log utility for framework internal use
@objcMembers public class ALog: NSObject {
    /// Current log display level
    public static var displayLevel: ALogDisplayLevel = .none
    
    /// Log message
    /// - Parameters:
    ///   - type: Log type
    ///   - message: Log message
    public static func log(_ type: ALogType, _ message: String) {
        switch displayLevel {
        case .none:
            // Only show errors
            guard type == .error else { return }
        case .normal:
            // Show error, warning, info
            guard type != .debug else { return }
        case .full:
            // Show all logs
            break
        }
        
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        let levelPrefix = levelPrefix(for: type)
        print("[AsgardCore \(timestamp)] \(levelPrefix) \(message)")
    }
    
    /// Get log level prefix
    private static func levelPrefix(for type: ALogType) -> String {
        switch type {
        case .error: return "ERROR"
        case .warning: return "WARN"
        case .info: return "INFO"
        case .debug: return "DEBUG"
        }
    }
    
    /// Debug log
    public static func debug(_ message: String) {
        log(.debug, message)
    }
    
    /// Info log
    public static func info(_ message: String) {
        log(.info, message)
    }
    
    /// Warning log
    public static func warning(_ message: String) {
        log(.warning, message)
    }
    
    /// Error log
    public static func error(_ message: String) {
        log(.error, message)
    }
} 
