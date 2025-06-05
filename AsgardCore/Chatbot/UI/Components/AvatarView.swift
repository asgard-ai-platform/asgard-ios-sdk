import SwiftUI

struct AvatarView: View {
    let url: String
    @State private var image: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 32, height: 32)
            }
        }
        .onAppear {
            loadImage()
        }
        .onDisappear {
            // Clear image from memory when view disappears
            image = nil
        }
    }
    
    private func loadImage() {
        ImageLoader.shared.loadImage(from: url) { downloadedImage in
            DispatchQueue.main.async {
                self.image = downloadedImage
                self.isLoading = false
            }
        }
    }
}
