import SwiftUI

struct MessageBubble: View {
    let message: AsgardChatMessage
    let theme: AsgardThemeConfig
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            if message.messageType == .user {
                Spacer()
                Text(message.timeString)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
                Text(message.text ?? "")
                    .padding()
                    .background(theme.userMessage.backgroundColor)
                    .foregroundColor(theme.userMessage.textColor)
                    .clipShape(BubbleShape(isUser: true))
            } else {
                Text(message.text ?? "")
                    .padding()
                    .background(theme.botMessage.backgroundColor)
                    .foregroundColor(theme.botMessage.textColor)
                    .clipShape(BubbleShape(isUser: false))
                Text(message.timeString)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.bottom, 2)
                Spacer()
            }
        }
        .padding(message.messageType == .user ? .leading : .trailing, 40)
        .padding(.vertical, 2)
    }
} 