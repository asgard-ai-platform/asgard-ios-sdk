import SwiftUI
import UIKit

struct FullScreenBackgroundView: UIViewRepresentable {
    var color: UIColor
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = color
        }
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.backgroundColor = color
    }
}

public struct AsgardChatbotView: View {
    @StateObject public var viewModel: AsgardChatbotViewModel
    public let isModal: Bool
    
    public init(viewModel: AsgardChatbotViewModel, isModal: Bool = true) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.isModal = isModal

        DispatchQueue.main.async {
            viewModel.chatbot.start()
        }
    }
    
    public var body: some View {
        ChatInterfaceView(viewModel: viewModel)
            .asgardTheme(viewModel.uiConfig.theme)
    }
}

private struct ChatInterfaceView: View {
    @ObservedObject var viewModel: AsgardChatbotViewModel
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            ChatHistoryView(viewModel: viewModel)
            if viewModel.isTyping {
                BotTypingPlaceholderView(text: viewModel.uiConfig.botTypingPlaceholder)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 2)
                    .background(viewModel.uiConfig.theme.chatbot.backgroundColor)
            }
            
            ChatInputBar(
                text: $viewModel.inputText,
                onSend: {
                    Task {
                        await viewModel.sendMessage()
                    }
                },
                isLoading: viewModel.isLoading,
                theme: viewModel.uiConfig.theme,
                enableSpeechRecognition: viewModel.uiConfig.enableSpeechRecognition
            )
        }
    }
}

private struct ChatHistoryView: View {
    @ObservedObject var viewModel: AsgardChatbotViewModel
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        if message.messageType == .bot {
                            HStack(alignment: .bottom, spacing: 8) {
                                if let avatarURL = viewModel.uiConfig.avatar {
                                    AvatarView(url: avatarURL)
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray.opacity(0.5))
                                        .frame(width: 32, height: 32)
                                }
                                MessageBubble(message: message, theme: viewModel.uiConfig.theme)
                            }
                            .id(message.id)
                        } else {
                            MessageBubble(message: message, theme: viewModel.uiConfig.theme)
                                .id(message.id)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .modifier(ScrollDismissKeyboardModifier())
            .ignoresSafeArea(.keyboard, edges: .all)
            .background(viewModel.uiConfig.theme.chatbot.backgroundColor)
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .onChange(of: viewModel.messages) { messages in
                withAnimation {
                    if let lastMessage = messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

private struct ScrollDismissKeyboardModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.scrollDismissesKeyboard(.immediately)
        } else {
            content
        }
    }
}

private struct BotTypingPlaceholderView: View {
    let text: String
    @State private var dots: String = ""
    @State private var timer: Timer?
    
    var body: some View {
        Text(text + dots)
            .foregroundColor(.gray)
            .font(.system(size: 12))
            .frame(height: 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
            .padding(.bottom, 0)
            .onAppear {
                startAnimation()
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
    }
    
    private func startAnimation() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if dots.count >= 3 {
                dots = ""
            } else {
                dots += "."
            }
        }
    }
}

private func popOrDismiss() {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let root = scene.windows.first?.rootViewController else { return }
    let top = topViewController(root)
    if let nav = top.navigationController, nav.viewControllers.count > 1 {
        nav.popViewController(animated: true)
    } else {
        top.dismiss(animated: true)
    }
}

private func topViewController(_ root: UIViewController) -> UIViewController {
    if let presented = root.presentedViewController {
        return topViewController(presented)
    }
    if let nav = root as? UINavigationController {
        return nav.visibleViewController ?? nav
    }
    if let tab = root as? UITabBarController {
        return tab.selectedViewController ?? tab
    }
    return root
}
