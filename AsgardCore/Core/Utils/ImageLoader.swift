import UIKit

/// A utility class for loading and caching images
public class ImageLoader {
    /// Shared instance
    public static let shared = ImageLoader()
    
    /// Memory cache for images
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Set cache limits
        cache.countLimit = 100 // Maximum number of images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
    }
    
    /// Load image from URL
    /// - Parameters:
    ///   - url: Image URL
    ///   - completion: Completion handler with loaded image
    public func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check cache first
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
            return
        }
        
        // Download image if not in cache
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Cache the downloaded image
            self.cache.setObject(image, forKey: url.absoluteString as NSString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    /// Load image from URL string
    /// - Parameters:
    ///   - urlString: Image URL string
    ///   - completion: Completion handler with loaded image
    public func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        loadImage(from: url, completion: completion)
    }
    
    /// Clear all cached images
    public func clearCache() {
        cache.removeAllObjects()
    }
    
    /// Remove specific image from cache
    /// - Parameter urlString: URL string of the image to remove
    public func removeFromCache(urlString: String) {
        cache.removeObject(forKey: urlString as NSString)
    }
} 