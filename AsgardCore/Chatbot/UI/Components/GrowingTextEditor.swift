import SwiftUI

struct GrowingTextEditor: UIViewRepresentable {
    @Binding var text: String
    var minHeight: CGFloat
    var maxHeight: CGFloat
    @Binding var dynamicHeight: CGFloat
    var textColor: Color = .primary
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isScrollEnabled = true
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.showsVerticalScrollIndicator = true
        textView.textColor = UIColor(textColor)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        uiView.textColor = UIColor(textColor)
        GrowingTextEditor.recalculateHeight(view: uiView, result: $dynamicHeight, minHeight: minHeight, maxHeight: maxHeight)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, dynamicHeight: $dynamicHeight, minHeight: minHeight, maxHeight: maxHeight)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var dynamicHeight: Binding<CGFloat>
        var minHeight: CGFloat
        var maxHeight: CGFloat
        
        init(text: Binding<String>, dynamicHeight: Binding<CGFloat>, minHeight: CGFloat, maxHeight: CGFloat) {
            self.text = text
            self.dynamicHeight = dynamicHeight
            self.minHeight = minHeight
            self.maxHeight = maxHeight
        }
        
        func textViewDidChange(_ textView: UITextView) {
            text.wrappedValue = textView.text
            GrowingTextEditor.recalculateHeight(view: textView, result: dynamicHeight, minHeight: minHeight, maxHeight: maxHeight)
        }
    }
    
    static func recalculateHeight(view: UIView, result: Binding<CGFloat>, minHeight: CGFloat, maxHeight: CGFloat) {
        let newSize = view.sizeThatFits(CGSize(width: view.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let clamped = min(max(newSize.height, minHeight), maxHeight)
        if result.wrappedValue != clamped {
            DispatchQueue.main.async {
                result.wrappedValue = clamped
            }
        }
    }
} 
