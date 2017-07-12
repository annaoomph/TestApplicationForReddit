//
//  ImageUtilities.swift
//  testreddit
//
//  Created by Anna on 7/4/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

import UIKit

private let _sharedCache = ImageCache()

/// A simple class storing image cache for current session.
class ImageCache {
    
    /// Maximum size of the cache, reaching which it is cleared.
    private let maxSize = 50
    
    /// Dictionary of stored images.
    var images = [String:UIImage]() {
        didSet {
            if images.count > maxSize {
                images = [String:UIImage]()
            }
        }
    }
    
    class var sharedCache: ImageCache {
        return _sharedCache
    }
    
    /// Stores an image in the cache.
    ///
    /// - Parameters:
    ///   - image: image to be stored.
    ///   - key: key for storing that image.
    func setImage(image: UIImage, forKey key: String) {        
        images[key] = image
    }
    
    /// Gets an image by its key.
    ///
    /// - Parameter key: key to get the image.
    /// - Returns: Image, if exists.
    func imageForKey(key: String) -> UIImage? {
        return images[key]
    }
}
