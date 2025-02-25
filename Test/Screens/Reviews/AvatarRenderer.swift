//
//  AvatarRenderer.swift
//  Test
//
//  Created by Fadey Notchenko on 25.02.2025.
//

import UIKit

// MARK: - Image Cache

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {}

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func clearCache() {
        cache.removeAllObjects()
    }
}

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

/// Класс рисует изображение из URL или ассетов с круглой маской.
final class AvatarRenderer {
    private let config: AvatarRendererConfig
    private let imageRenderer: UIGraphicsImageRenderer

    init(config: AvatarRendererConfig, imageRenderer: UIGraphicsImageRenderer) {
        self.config = config
        self.imageRenderer = imageRenderer
    }
}

// MARK: - Internal

extension AvatarRenderer {
    convenience init(config: AvatarRendererConfig = .default()) {
        let imageRenderer = UIGraphicsImageRenderer(size: config.size)
        self.init(config: config, imageRenderer: imageRenderer)
    }
    
    func getDefaultImage() -> UIImage? {
        return drawImage(fromAsset: config.placeholderImageName)
    }

    /// Асинхронно загружает и рендерит изображение.
    /// completion: Замыкание, которое вызывается с результатом (UIImage?).
    func renderImage(url: String?, completion: @escaping (UIImage?) -> Void) {
        guard let url = url, let imageURL = URL(string: url) else {
            let placeholderImage = drawImage(fromAsset: config.placeholderImageName)
            completion(placeholderImage)
            return
        }

        let cacheKey = imageURL.absoluteString as NSString

        if let cachedImage = ImageCache.shared.getImage(forKey: cacheKey as String) {
            completion(cachedImage)
            return
        }

        // Загрузка изображения из URL
        DispatchQueue.global(qos: .userInitiated).async {
            if let data = try? Data(contentsOf: imageURL), let downloadedImage = UIImage(data: data) {
                let renderedImage = self.drawImage(from: downloadedImage)

                // Сохраняем в кэш
                ImageCache.shared.setImage(renderedImage, forKey: cacheKey as String)

                DispatchQueue.main.async {
                    completion(renderedImage)
                }
            } else {
                // Если загрузка не удалась, используем плейсхолдер
                let placeholderImage = self.drawImage(fromAsset: self.config.placeholderImageName)
                DispatchQueue.main.async {
                    completion(placeholderImage)
                }
            }
        }
    }
}

// MARK: - Private

private extension AvatarRenderer {
    /// Рендерит изображение из ассетов с круглой маской.
    func drawImage(fromAsset imageName: String) -> UIImage? {
        guard let originalImage = UIImage(named: imageName) else {
            return nil
        }

        return imageRenderer.image { context in
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: config.size))
            path.addClip()
            originalImage.draw(in: CGRect(origin: .zero, size: config.size))
        }
    }

    /// Рендерит изображение из загруженного UIImage с круглой маской.
    func drawImage(from image: UIImage) -> UIImage {
        return imageRenderer.image { context in
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: config.size))
            path.addClip()
            image.draw(in: CGRect(origin: .zero, size: config.size))
        }
    }
}
