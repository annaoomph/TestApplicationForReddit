//
//  ImageUtilities.swift
//  testreddit
//
//  Created by Alexander on 7/4/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

import UIKit

private let _sharedCache = ImageCache()

class ImageCache {
    var images = [String:UIImage]()
    
    class var sharedCache: ImageCache {
        return _sharedCache
    }
    
    func setImage(image: UIImage, forKey key: String) {
        images[key] = image
    }
    
    func imageForKey(key: String) -> UIImage? {
        return images[key]
    }
}
