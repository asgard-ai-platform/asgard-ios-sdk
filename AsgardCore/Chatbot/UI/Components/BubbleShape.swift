import SwiftUI

struct BubbleShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let radius: CGFloat = 20
        var corners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
        if isUser {
            corners.remove(.bottomRight)
        } else {
            corners.remove(.bottomLeft)
        }
        return Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
} 