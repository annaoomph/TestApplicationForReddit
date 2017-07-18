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

/// A flexible image cahce class allowing store cache both on disk and in internal memory.
class ImageCache {
    
    /// Whether images for cache should be stored on disk.
    static var CACHE_ON_DISK = true
    
    /// Maximum size of the cache, reaching which it is cleared.
    private let maxSize = 50
    
    /// Maximum size of the cache on disk (can be higher, because this data is preserved between sessions).
    private let maxDiskSize = 100
    
    /// Path for storing images on disk.
    private var path: String
    
    /// FileManager to work with the file system.
    private let fileManager = FileManager.default
    
    init() {
        var home = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        path = home[0].appending("/Caches")
        if !fileManager.fileExists(atPath: path) {
            do {
                //If an attempt to create a directory failed, turn off this feature.
                if (try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: [:])) == nil {
                    ImageCache.CACHE_ON_DISK = false
                }
            }
        }
    }
    
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
    ///   - isGif: whether this is a gif image.
    func setImage(image: UIImage, forKey key: String, isGif: Bool) {
        if ImageCache.CACHE_ON_DISK && !isGif {
            checkOverflow()
            let imagePath = path.appending("/\(convertToKeyImageUrl(key))")
            if !fileManager.fileExists(atPath: imagePath) {
                FileManager.default.createFile(atPath: imagePath, contents: UIImageJPEGRepresentation(image, 1.0), attributes: [:])
            }
        } else {
            images[key] = image
        }
    }
    
    /// Gets an image by its key.
    ///
    /// - Parameter key: key to get the image.
    /// - Parameter isGif: whether this is a gif image.
    /// - Returns: Image, if exists.
    func imageForKey(key: String, isGif: Bool) -> UIImage? {
        //Gifs are not stored on the disk cause we have no access to their data.
        if ImageCache.CACHE_ON_DISK && !isGif {
            let imagePath = path.appending("/\(convertToKeyImageUrl(key))")
            if fileManager.fileExists(atPath: imagePath) {
                if let data = fileManager.contents(atPath: imagePath) {
                    return UIImage(data: data)
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } else {
            return images[key]
        }
    }
    
    /// Checks whether it is time to clear data on disk.
    private func checkOverflow() {
        do {
            if let directory = try? fileManager.contentsOfDirectory(atPath: path) {
                if directory.count > maxDiskSize {
                    try! fileManager.removeItem(atPath: path)
                    
                    //Recreate deleted directyory.
                    if (try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: [:])) == nil {
                        ImageCache.CACHE_ON_DISK = false
                    }
                }
            }
        }
    }
    
    /// Converts image url to an appropriate unique name for storing on disk.
    ///
    /// - Parameter url: image url.
    /// - Returns: a unique key.
    private func convertToKeyImageUrl(_ url: String) -> String {
        return "CACHEDIMAGE_\(String(url.hashValue))"
    }
}
