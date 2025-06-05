import SwiftUI

struct ChatbotContentView: View {
    @ObservedObject var viewModel: AsgardChatbotViewModel

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(viewModel.messages) { message in
                    messageBubble(message)
                }
            }
        }
    }

    private func messageBubble(_ message: AsgardChatMessage) -> some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.messageType == .bot {
                // Bot avatar
                if let avatarURL = viewModel.uiConfig.avatar {
                    AvatarView(url: avatarURL)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                }
            }
            
            // Message bubble
            Text(message.displayText)
                .font(.system(size: 16))
                .foregroundColor(message.messageType == .user ? viewModel.uiConfig.theme.userMessage.textColor : viewModel.uiConfig.theme.botMessage.textColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    message.messageType == .user ?
                    viewModel.uiConfig.theme.userMessage.backgroundColor :
                    viewModel.uiConfig.theme.botMessage.backgroundColor
                )
                .clipShape(
                    message.messageType == .user ?
                    ChatBubbleShape(isUser: true) :
                    ChatBubbleShape(isUser: false)
                )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// Custom bubble shape
struct ChatBubbleShape: Shape {
    let isUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: isUser ?
                [.topLeft, .topRight, .bottomLeft] :  // User: top-right corner
                [.topRight, .bottomLeft, .bottomRight], // Bot: top-left corner
            cornerRadii: CGSize(width: 16, height: 16)
        )
        return Path(path.cgPath)
    }
} 
