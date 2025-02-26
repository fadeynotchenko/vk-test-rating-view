//
//  ImageCache.swift
//  Test
//
//  Created by Fadey Notchenko on 25.02.2025.
//

import UIKit

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
