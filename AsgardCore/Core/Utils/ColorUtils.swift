import SwiftUI

// MARK: - Color Extension
public extension Color {
    static let themeColor = Color(hex: "#1A1A1A")
    static let botMessageBoxColor = Color(hex: "#3C3C3C")
    static let botMessageTextColor = Color(hex: "#FFFFFF")
    static let userMessageBoxColor = Color(hex: "#2C2C2C")
    static let userMessageTextColor = Color(hex: "#FFFFFF")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // 判斷顏色是否為淺色
    var isLight: Bool {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // 計算顏色的亮度
        let brightness = ((red * 299) + (green * 587) + (blue * 114)) / 1000
        
        // 如果亮度大於 0.5，則認為是淺色
        return brightness > 0.5
    }
}