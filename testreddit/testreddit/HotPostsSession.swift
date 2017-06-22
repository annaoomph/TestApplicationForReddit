//
//  HotPostsSession.swift
//  testreddit
//
//  Created by Alexander on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation


/// A session that retrieves hot posts from reddit.
public class HotPostsSession: BaseSession {
    
    static let POSTS_URL = "https://oauth.reddit.com/hot"
    
    
    /// Request the first 25 posts.
    ///
    /// - Parameter callback: delegate
    func requestPosts(callback: HotPostsDelegate? = nil) {
        let url = URL(string: HotPostsSession.POSTS_URL);
        makeRequest(url: url!, authorization: getToken(), httpMethod: .get, callback: {json, errString in
            if let error = errString {
                if let delegate = callback {
                    delegate.onError(error: error)
                }
            } else {
                if let dictionary = json {
                    CoreDataManager.instance.clear()
                    if let items = PostsParser().parseItems(json: dictionary) {
                        CoreDataManager.instance.saveContext()
                        if let delegate = callback {                           
                            delegate.onPostsDelivered(posts: items)                            
                        }
                    } else {
                        if let delegate = callback {
                            delegate.onError(error: "Could not get items.")
                        }
                    }
                    
                }
            }
        })
    }
    
    
    /// Request the posts after some post.
    ///
    /// - Parameter callback: delegate
    func requestMorePosts(callback: HotPostsDelegate? = nil) {
        var urlString = HotPostsSession.POSTS_URL
        if let parameters = PostsParser.LAST_POST {
            urlString.append("?after=\(parameters)")
        }
        let url = URL(string: urlString);
        makeRequest(url: url!, authorization: getToken(), httpMethod: .get, callback: {json, errString in
            if let error = errString {
                if let delegate = callback {
                    delegate.onError(error: error)
                }
            } else {
                if let dictionary = json {
                    if let items = PostsParser().parseItems(json: dictionary) {
                        CoreDataManager.instance.saveContext()
                        if let delegate = callback {
                            delegate.onMorePostsDelivered(posts: items)
                        }
                    } else {
                        if let delegate = callback {
                            delegate.onError(error: "Could not get items.")
                        }
                    }
                    
                }
            }
        })
    }

}
