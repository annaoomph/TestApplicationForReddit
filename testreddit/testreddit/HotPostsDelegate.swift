//
//  HotPostsDelegate.swift
//  testreddit
//
//  Created by Alexander on 6/15/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation


/// A delegate for getting hot posts from the server.
protocol HotPostsDelegate {
    
    
    /// Called when posts arrived.
    ///
    /// - Parameter posts: a list of posts
    func onPostsDelivered(posts: [LinkM])
    
    
    /// Called when more posts arrived.
    ///
    /// - Parameter posts: a list of posts.
    func onMorePostsDelivered(posts: [LinkM])
    
    
    /// Called when some error occurred.
    ///
    /// - Parameter error: a string describing the error
    func onError(error: String)
}
