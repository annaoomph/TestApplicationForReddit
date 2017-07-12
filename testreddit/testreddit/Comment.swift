//
//  Comment.swift
//  testreddit
//
//  Created by Anna on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SwiftyJSON

/// A class describing a reddit comment (can include a tree of replies of the same type).
public class Comment: NSObject {
    
    /// Whether the comment is expanded in comment tree (used for interface).
    var opened: Bool
    
    /// Comment score (likes - dislikes).
    var score: Int
    
    /// The time of creation in local epoch-second format.
    var created: Int
    
    /// The account name of the poster.
    var author: String
    
    /// The raw text. This is the unformatted text which includes the raw markup characters.
    var body: String
    
    /// A list of replies to the comment.
    var replies: [Comment]?
    
    init?(JSONData: JSON) {
        guard let score = JSONData["score"].int,
            let created = JSONData["created"].int,
            let author = JSONData["author"].string,
            let body = JSONData["body"].string else {
                return nil
        }
        self.score = score
        self.created = created
        self.author = author
        self.body = body
        //Parse subcomments recursively.
        self.replies = CommentsParser().parseItems(json: JSONData["replies"], inner: false)
        self.opened = false
        super.init()
    }
    
    /// Tries to get a subcomment by the given index. Can fail if the index is too large, or the comment is not opened.
    ///
    /// - Parameter replyIndex: index of the possible subcomment.
    subscript(_ replyIndex: Int) -> Comment? {
        if self.opened {
            if self.replies?.count ?? 0 > replyIndex {
                return self.replies![replyIndex]
            }
        }
        return nil
    }
}
