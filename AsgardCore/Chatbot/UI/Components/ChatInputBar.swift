import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    var onSend: () -> Void
    var isLoading: Bool = false
    var theme: AsgardThemeConfig
    var enableSpeechRecognition: Bool = false
    @State private var dynamicHeight: CGFloat = 24
    @State private var showSpeechRecognition = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("Enter message")
                            .foregroundColor(.gray)
                            .padding(.leading, 12)
                            .padding(.top, 8)
                    }
                    GrowingTextEditor(
                        text: $text,
                        minHeight: 24,
                        maxHeight: 72,
                        dynamicHeight: $dynamicHeight,
                        textColor: theme.userMessage.textColor
                    )
                    .frame(minHeight: dynamicHeight, maxHeight: dynamicHeight)
                    .background(Color.clear)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.userMessage.textColor, lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: 72)

                ZStack {
                    // Loading state
                    ProgressView()
                        .accentColor(theme.userMessage.textColor)
                        .opacity(isLoading ? 1 : 0)

                    // Send button
                    Button(action: {
                        if !text.isEmpty { onSend() }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(theme.userMessage.backgroundColor)
                    }
                    .opacity(!isLoading && !text.isEmpty ? 1 : 0)
                    .disabled(isLoading || text.isEmpty)

                    // Microphone button (only shown when speech recognition is enabled)
                    if enableSpeechRecognition {
                        Button(action: {
                            showSpeechRecognition = true
                        }) {
                            Image(systemName: "mic.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(theme.userMessage.backgroundColor)
                        }
                        .opacity(!isLoading && text.isEmpty ? 1 : 0)
                    } else {
                        Button(action: {}) {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(theme.userMessage.backgroundColor)
                        }
                        .opacity(!isLoading ? 1 : 0)
                        .disabled(isLoading)
                    }
                }
                .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 0)
        .fullScreenCover(isPresented: $showSpeechRecognition) {
            SpeechRecognitionView(recognizedText: $text)
        }
    }
} 
