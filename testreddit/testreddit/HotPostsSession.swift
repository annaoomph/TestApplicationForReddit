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
    
    func requestPosts(callback: TokenDelegate) {
        let url = URL(string: HotPostsSession.POSTS_URL);
        makeGetRequest(url: url!, callback: {json in
            
            
        })
    }
}
