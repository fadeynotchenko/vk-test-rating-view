//
//  AvatarRenderer.swift
//  Test
//
//  Created by Fadey Notchenko on 25.02.2025.
//

import UIKit

struct AvatarRendererConfig {
    let imageName: String
    let size: CGSize
}

// MARK: - Internal

extension AvatarRendererConfig {
    static func `default`() -> Self {
        return AvatarRendererConfig(
            imageName: "l5w5aIHioYc",
            size: CGSize(width: 40.0, height: 40.0)
        )
    }
}

// MARK: - Renderer

/// Класс рисует изображение из ассетов с круглой маской.
final class AvatarRenderer {
    private let config: AvatarRendererConfig
    private var cachedImage: UIImage?
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

    func renderImage() -> UIImage? {
        if let cachedImage = cachedImage {
            return cachedImage
        }
        
        let renderedImage = drawImage()
        cachedImage = renderedImage
        
        return renderedImage
    }
}

// MARK: - Private

private extension AvatarRenderer {
    func drawImage() -> UIImage? {
        guard let originalImage = UIImage(named: config.imageName) else {
            return nil
        }

        let renderedImage = imageRenderer.image { context in
            let path = UIBezierPath(ovalIn: CGRect(origin: .zero, size: config.size))
            path.addClip()

            originalImage.draw(in: CGRect(origin: .zero, size: config.size))
        }

        return renderedImage
    }
}
