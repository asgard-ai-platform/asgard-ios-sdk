import SwiftUI

struct URLImage: View {
    let url: URL?
    var placeholder: Image = Image(systemName: "person.circle.fill")
    var size: CGFloat = 32

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                placeholder
                    .resizable()
                    .foregroundColor(.gray.opacity(0.5))
                    .onAppear {
                        loadImage()
                    }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private func loadImage() {
        guard let url = url, uiImage == nil else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.uiImage = image
                }
            }
        }.resume()
    }
} 