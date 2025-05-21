import Foundation

/// Log Manager
public enum LogManager {
    /// Key for log storage
    private static let logStorageKey = "com.asgardcore.logs"
    /// Maximum number of logs
    private static let maxLogCount = 1000
    /// Buffer size
    private static let bufferSize = 100
    /// Write interval (seconds)
    private static let writeInterval: TimeInterval = 1.0
    
    /// Memory buffer
    private static var buffer: [[String: String]] = []
    /// Write timer
    private static var writeTimer: Timer?
    /// Write queue
    private static let writeQueue = DispatchQueue(label: "com.asgardcore.logmanager.write", qos: .utility)
    /// Read queue
    private static let readQueue = DispatchQueue(label: "com.asgardcore.logmanager.read", qos: .userInitiated)
    
    /// Store log
    /// - Parameter log: Log content
    public static func store(_ log: [String: String]) {
        // Add timestamp
        var logWithTime = log
        logWithTime["timestamp"] = Date().timeIntervalSince1970.description
        
        // Add to buffer
        writeQueue.async {
            buffer.append(logWithTime)
            
            // If buffer is full, write immediately
            if buffer.count >= bufferSize {
                flushBuffer()
            }
            
            // Ensure timer is running
            ensureTimer()
        }
    }
    
    /// Ensure timer is running
    private static func ensureTimer() {
        if writeTimer == nil {
            writeTimer = Timer.scheduledTimer(withTimeInterval: writeInterval, repeats: true) { _ in
                flushBuffer()
            }
        }
    }
    
    /// Flush buffer to storage
    private static func flushBuffer() {
        guard !buffer.isEmpty else { return }
        
        writeQueue.async {
            // Read existing logs
            var logs = loadLogs()
            
            // Add buffer contents
            logs.append(contentsOf: buffer)
            
            // Limit log count
            if logs.count > maxLogCount {
                logs = Array(logs.suffix(maxLogCount))
            }
            
            // Save logs
            if let data = try? JSONSerialization.data(withJSONObject: logs) {
                UserDefaults.standard.set(data, forKey: logStorageKey)
            }
            
            // Clear buffer
            buffer.removeAll()
        }
    }
    
    /// Load logs
    /// - Returns: Array of logs
    public static func loadLogs() -> [[String: String]] {
        guard let data = UserDefaults.standard.data(forKey: logStorageKey),
              let logs = try? JSONSerialization.jsonObject(with: data) as? [[String: String]] else {
            return []
        }
        return logs
    }
    
    /// Clear logs
    public static func clearLogs() {
        writeQueue.async {
            UserDefaults.standard.removeObject(forKey: logStorageKey)
            buffer.removeAll()
        }
    }
    
    /// Export logs
    /// - Returns: Log string
    public static func exportLogs() -> String {
        let logs = loadLogs()
        var logString = ""
        
        for log in logs {
            if let timestamp = log["timestamp"],
               let timeInterval = Double(timestamp) {
                let date = Date(timeIntervalSince1970: timeInterval)
                let dateString = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .medium)
                logString += "[\(dateString)]\n"
            }
            
            for (key, value) in log where key != "timestamp" {
                logString += "\(key): \(value)\n"
            }
            logString += "\n"
        }
        
        return logString
    }
} 