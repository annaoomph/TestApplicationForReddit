//
//  HotPostsSession.swift
//  testreddit
//
//  Created by Alexander on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

public class HotPostsSession: BaseSession {
    
    static let POSTS_URL = "https://oauth.reddit.com/hot"
    
    func requestPosts(callback: HotPostsDelegate? = nil) {
        
        let url = URL(string: HotPostsSession.POSTS_URL);
        makeRequest(url: url!, authorization: getToken(), httpMethod: .get, callback: {json, errString in
            if let error = errString {
                if let delegate = callback {
                    delegate.onError(error: error)
                }
            } else {
                if let dictionary = json {
                    if let items = Parser().parseItems(json: dictionary) {
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
}
