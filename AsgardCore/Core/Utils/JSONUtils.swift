import Foundation

/// JSON utility class
public enum JSONUtils {
    /// JSON parsing error
    public enum JSONError: Error {
        case invalidString
        case decodeFailed(Error)
        case encodeFailed(Error)
        case serializationFailed(Error)
        
        var localizedDescription: String {
            switch self {
            case .invalidString:
                return "Invalid JSON string"
            case .decodeFailed(let error):
                return "Failed to decode JSON: \(error.localizedDescription)"
            case .encodeFailed(let error):
                return "Failed to encode JSON: \(error.localizedDescription)"
            case .serializationFailed(let error):
                return "Failed to serialize JSON: \(error.localizedDescription)"
            }
        }
    }
    
    /// Convert Codable object to JSON string
    /// - Parameters:
    ///   - object: Object to convert
    ///   - prettyPrinted: Whether to format output
    /// - Returns: JSON string
    public static func stringify<T: Codable>(_ object: T, prettyPrinted: Bool = true) -> String? {
        do {
            let encoder = JSONEncoder()
            if prettyPrinted {
                encoder.outputFormatting = .prettyPrinted
            }
            let jsonData = try encoder.encode(object)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            ALog.error("Failed to encode object: \(error)")
            return nil
        }
    }
    
    /// Convert JSON string to object
    /// - Parameters:
    ///   - jsonString: JSON string
    ///   - type: Target type
    /// - Returns: Converted object
    public static func parse<T: Codable>(_ jsonString: String, as type: T.Type) -> T? {
        guard let jsonData = jsonString.data(using: .utf8) else {
            ALog.error(JSONError.invalidString.localizedDescription)
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: jsonData)
        } catch {
            ALog.error(JSONError.decodeFailed(error).localizedDescription)
            return nil
        }
    }
    
    /// Convert Data to object
    /// - Parameters:
    ///   - data: JSON data
    ///   - type: Target type
    /// - Returns: Converted object
    public static func parse<T: Codable>(_ data: Data, as type: T.Type) -> T? {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(type, from: data)
        } catch {
            ALog.error(JSONError.decodeFailed(error).localizedDescription)
            return nil
        }
    }
    
    /// Convert object to dictionary
    /// - Parameter object: Object to convert
    /// - Returns: Dictionary
    public static func toDictionary<T: Codable>(_ object: T) -> [String: Any]? {
        guard let jsonString = stringify(object, prettyPrinted: false),
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        } catch {
            ALog.error(JSONError.serializationFailed(error).localizedDescription)
            return nil
        }
    }
} 