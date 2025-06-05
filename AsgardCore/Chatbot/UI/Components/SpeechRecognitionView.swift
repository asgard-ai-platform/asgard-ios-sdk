import SwiftUI
import Speech

// Blur effect view
struct VisualEffectView: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let style: UIBlurEffect.Style = colorScheme == .dark ? .dark : .light
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        let style: UIBlurEffect.Style = colorScheme == .dark ? .dark : .light
        uiView.effect = UIBlurEffect(style: style)
    }
}

// Transparent background view
struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

// Listening animation view
struct ListeningAnimationView: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: 0.5)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// Speech recognition manager
class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var recognizedText = ""
    @Published var statusText = "請開始說話"
    @Published var isRecording = false
    var onSpeechEnd: (() -> Void)?
    var onAuthorizationGranted: (() -> Void)?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-TW"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var emptyTimer: Timer?
    private var silenceTimer: Timer?
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
    }
    
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    // Speech recognition permission granted, continue checking microphone permission
                    AVAudioSession.sharedInstance().requestRecordPermission { granted in
                        DispatchQueue.main.async {
                            if granted {
                                self?.statusText = "請開始說話"
                                self?.onAuthorizationGranted?()
                            } else {
                                self?.statusText = "您未允許使用麥克風權限，\n無法使用此功能。\n\n請開啟手機的系統設定，\n打開麥克風的允許權限。"
                            }
                        }
                    }
                case .denied:
                    self?.statusText = "您未允許使用語音辨識權限，\n無法使用此功能。\n\n請開啟手機的系統設定，\n打開語音辨識的允許權限。"
                case .restricted:
                    self?.statusText = "此裝置不支援語音辨識"
                case .notDetermined:
                    self?.statusText = "請允許使用語音辨識"
                @unknown default:
                    self?.statusText = "未知錯誤"
                }
            }
        }
    }
    
    func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            statusText = "語音辨識不可用"
            return
        }
        
        // Reset previous task
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        // Reset state
        recognizedText = ""
        statusText = "正在聆聽..."
        isRecording = true
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            statusText = "無法設置語音會話"
            return
        }
        
        // Ensure cleanup of previous recording setup
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else {
            statusText = "無法創建語音辨識請求"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.taskHint = .unspecified
        
        // Create new recognition task
        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
                self.statusText = "正在聆聽..."
                
                // Reset silence timer
                self.resetSilenceTimer()
            }
            
            if let error = error {
                ALog.error("Speech recognition error: \(error.localizedDescription)")
                self.stopRecording()
            }
        }
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            // Start empty text timer
            resetEmptyTimer()
        } catch {
            statusText = "無法啟動語音辨識"
            return
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        // Stop all timers
        emptyTimer?.invalidate()
        silenceTimer?.invalidate()
        emptyTimer = nil
        silenceTimer = nil
        
        isRecording = false
    }
    
    // Reset empty text timer
    func resetEmptyTimer() {
        emptyTimer?.invalidate()
        emptyTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if self.recognizedText.isEmpty {
                DispatchQueue.main.async {
                    self.statusText = "聽不太清楚\n\n請點擊下方麥克風圖示，\n再試一次。"
                    self.stopRecording()
                }
            }
        }
    }
    
    // Reset silence timer
    func resetSilenceTimer() {
        silenceTimer?.invalidate()
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            if !self.recognizedText.isEmpty {
                self.stopRecording()
                DispatchQueue.main.async {
                    self.onSpeechEnd?()
                }
            }
        }
    }
    
    // MARK: - SFSpeechRecognizerDelegate
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition result: SFSpeechRecognitionResult) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.recognizedText = result.bestTranscription.formattedString
            self.stopRecording()
            self.onSpeechEnd?()
        }
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        if successfully {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.stopRecording()
                self.onSpeechEnd?()
            }
        }
    }
}

struct SpeechRecognitionView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.colorScheme) private var colorScheme
    @Binding var recognizedText: String
    
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @State private var isAnimating = false
    @State private var viewScale: CGFloat = 0.1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Transparent background
                BackgroundClearView()
                    .opacity(isAnimating ? 1 : 0)
                
                // Content view
                VStack(spacing: 32) {
                    // Title
                    Text(speechRecognizer.statusText)
                        .font(.system(size: 24, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.horizontal)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    // Recognized text
                    Text(speechRecognizer.recognizedText)
                        .font(.system(size: 24))
                        .multilineTextAlignment(.center)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .padding(.horizontal)
                        .opacity(isAnimating ? 1 : 0)
                        .offset(y: isAnimating ? 0 : 20)
                    
                    // Listening animation
                    if speechRecognizer.isRecording {
                        ListeningAnimationView()
                            .padding(.top, 20)
                            .opacity(isAnimating ? 1 : 0)
                            .scaleEffect(isAnimating ? 1 : 0.8)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 40) {
                        // Microphone button
                        Button(action: {
                            if speechRecognizer.isRecording {
                                speechRecognizer.stopRecording()
                                if !speechRecognizer.recognizedText.isEmpty {
                                    recognizedText = speechRecognizer.recognizedText
                                }
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isAnimating = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } else {
                                speechRecognizer.startRecording()
                            }
                        }) {
                            Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .foregroundColor(speechRecognizer.isRecording ? .red : Color(UIColor.tertiaryLabel))
                        }
                        
                        // Close button
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isAnimating = false
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                speechRecognizer.stopRecording()
                                presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                        .opacity(isAnimating ? 1 : 0)
                        .scaleEffect(isAnimating ? 1 : 0.8)
                    }
                    .padding(.bottom, 50)
                }
                .padding(.top, 100)
                .frame(width: geometry.size.width * 0.9)
                .background(VisualEffectView())
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 10)
                .scaleEffect(viewScale)
                .opacity(isAnimating ? 1 : 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            // Start animation
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isAnimating = true
                viewScale = 1.0
            }
            
            // Set speech end callback
            speechRecognizer.onSpeechEnd = {
                if !speechRecognizer.recognizedText.isEmpty {
                    recognizedText = speechRecognizer.recognizedText
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isAnimating = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
            // Set authorization success callback
            speechRecognizer.onAuthorizationGranted = {
                // Start recording automatically after permissions are granted
                speechRecognizer.startRecording()
            }
            
            // Request permissions
            speechRecognizer.requestAuthorization()
        }
        .onDisappear {
            // Ensure recording stops when view disappears
            if speechRecognizer.isRecording {
                speechRecognizer.stopRecording()
                if !speechRecognizer.recognizedText.isEmpty {
                    recognizedText = speechRecognizer.recognizedText
                }
            }
        }
    }
} 
