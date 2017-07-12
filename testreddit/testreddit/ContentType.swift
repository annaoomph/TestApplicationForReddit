//
//  ContentType.swift
//  testreddit
//
//  Created by Anna on 6/30/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// Internal application content type. Used to differentiate the thing application wants to fetch from server or to display.
///
/// - POSTS: posts, or links, as they're called in reddit.
/// - NEW: new posts.
/// - HOT: hot (trending) posts.
/// - COMMENTS: comments to posts.
enum ContentType: String {
    case POSTS = "posts"
    
    enum PostType: String {
        case NEW = "New Posts"
        case HOT = "Hot Posts"
        
        /// Gets post type by the index of the shown tab.
        ///
        /// - Parameter selectedTab: tab selected by user
        /// - Returns: post type
        static func getPostType(selectedTab: Int) -> PostType {
            if selectedTab == 0 {
                return .HOT
            } else {
                return .NEW
            }
        }
    }
    
    case COMMENTS = "comments"
}
