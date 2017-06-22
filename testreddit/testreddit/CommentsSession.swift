//
//  CommentsSession.swift
//  testreddit
//
//  Created by Alexander on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation


/// A session that gets the comments for some post from reddit.
public class CommentsSession: BaseSession {
    
    static let COMMENTS_URL = "https://oauth.reddit.com/comments/"
    
    
    /// Get comments for some post.
    ///
    /// - Parameters:
    ///   - postId: id of the particular post
    ///   - callback: delegate
    func getComments(postId: String, callback: CommentsDelegate? = nil) {
        let url = URL(string: "\(CommentsSession.COMMENTS_URL)\(postId)");
        makeRequest(url: url!, authorization: getToken(), httpMethod: .get, callback: {json, errString in
            if let error = errString {
                if let delegate = callback {
                    delegate.onError(error: error)
                }
            } else {
                if let dictionary = json {
                    if let items = CommentsParser().parseItems(json: dictionary, inner: false) {
                        if let delegate = callback {
                            delegate.onCommentsDelivered(comments: items)
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
