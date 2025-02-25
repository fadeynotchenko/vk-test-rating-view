//
//  AvatarRenderer.swift
//  Test
//
//  Created by Fadey Notchenko on 25.02.2025.
//

import UIKit

//
//  AvatarRenderer.swift
//  Test
//
//  Created by Fadey Notchenko on 25.02.2025.
//

// MARK: - AvatarRendererConfig

struct AvatarRendererConfig {
    
    let placeholderImageName: String
    let size: CGSize
    
}

// MARK: - Internal

extension AvatarRendererConfig {
    
    static func `default`() -> Self {
        return AvatarRendererConfig(
            placeholderImageName: "defaultAvatar",
            size: CGSize(width: 40.0, height: 40.0)
        )
    }
    
}

// MARK: - Renderer

final class AvatarRenderer {
    
    private let config: AvatarRendererConfig
    private let imageRenderer: UIGraphicsImageRenderer
    private let urlSession: URLSession
    private var tasks: [String: URLSessionDataTask] = [:]
    
    init(config: AvatarRendererConfig = .default(), urlSession: URLSession = .shared) {
        self.config = config
        self.imageRenderer = UIGraphicsImageRenderer(size: config.size)
        self.urlSession = urlSession
    }
    
}

// MARK: - Public Methods

extension AvatarRenderer {
    func getDefaultImage() -> UIImage? {
        let cacheKey = assetCacheKey(for: config.placeholderImageName)
        
        if let cachedImage = ImageCache.shared.getImage(forKey: cacheKey) {
            return cachedImage
        }
        
        return drawImage(fromAsset: config.placeholderImageName)
    }
    
    func renderImage(url: String?, completion: @escaping (UIImage?) -> Void) {
        guard let urlString = url, let url = URL(string: urlString) else {
            completion(getDefaultImage())
            
            return
        }
        
        let cacheKey = url.absoluteString
        
        if let cachedImage = ImageCache.shared.getImage(forKey: cacheKey) {
            completion(cachedImage)
            
            return
        }
        
        let task = urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self else { return }
            
            defer { self.tasks.removeValue(forKey: cacheKey) }
            
            if self.handleNetworkError(error: error, response: response, completion: completion) {
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                self.loadFallbackImage(completion: completion)
                
                return
            }
            
            let processedImage = self.drawImage(from: image)
            ImageCache.shared.setImage(processedImage, forKey: cacheKey)
            
            DispatchQueue.main.async {
                completion(processedImage)
            }
        }
        
        tasks[cacheKey] = task
        
        task.resume()
    }
}

// MARK: - Private Methods

private extension AvatarRenderer {
    func drawImage(fromAsset imageName: String) -> UIImage? {
        let cacheKey = assetCacheKey(for: imageName)
        
        if let cachedImage = ImageCache.shared.getImage(forKey: cacheKey) {
            return cachedImage
        }
        
        guard let originalImage = UIImage(named: imageName) else { return nil }
        
        let image = imageRenderer.image { context in
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: config.size))
            path.addClip()
            originalImage.draw(in: CGRect(origin: .zero, size: config.size))
        }
        
        ImageCache.shared.setImage(image, forKey: cacheKey)
        
        return image
    }
    
    func drawImage(from image: UIImage) -> UIImage {
        imageRenderer.image { context in
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: config.size))
            path.addClip()
            
            let imageSize = image.size
            let targetSize = config.size
            let widthRatio = targetSize.width / imageSize.width
            let heightRatio = targetSize.height / imageSize.height
            let scaleFactor = max(widthRatio, heightRatio)
            
            let scaledSize = CGSize(
                width: imageSize.width * scaleFactor,
                height: imageSize.height * scaleFactor
            )
            let origin = CGPoint(
                x: (targetSize.width - scaledSize.width) / 2,
                y: (targetSize.height - scaledSize.height) / 2
            )
            
            image.draw(in: CGRect(origin: origin, size: scaledSize))
        }
    }
    
    func handleNetworkError(error: Error?, response: URLResponse?, completion: @escaping (UIImage?) -> Void) -> Bool {
        if let error = error {
            print("Image load error: \(error.localizedDescription)")
            
            loadFallbackImage(completion: completion)
            
            return true
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Invalid server response")
            
            loadFallbackImage(completion: completion)
            
            return true
        }
        
        return false
    }
    
    func loadFallbackImage(completion: @escaping (UIImage?) -> Void) {
        let fallbackImage = getDefaultImage()
        
        DispatchQueue.main.async {
            completion(fallbackImage)
        }
    }
    
    func assetCacheKey(for imageName: String) -> String {
        "asset_\(imageName)"
    }
}
