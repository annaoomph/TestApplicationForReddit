//
//  Comment.swift
//  testreddit
//
//  Created by Alexander on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SwiftyJSON
/// A class describing a reddit comment (can include a tree of replies).
public class Comment: NSObject {
    
    
    /// Whether the comment is expanded in comment tree.
    var opened: Bool
    
    /// Comment score (likes - dislikes)
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
        self.replies = CommentsParser().parseItems(json: JSONData["replies"], inner: false)
        self.opened = false
        super.init()
    }
}
