//
//  Comment.swift
//  testreddit
//
//  Created by Alexander on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// A class describing a reddit comment (can include a tree of replies).
public class Comment: NSObject {
    
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
    
    init?(JSONData: NSDictionary!) {
        
        guard let score = JSONData["score"] as! Int?,
            let created = JSONData["created"] as! Int?,
            let author = JSONData["author"] as! String?,
            let body = JSONData["body"] as! String?
            else {
                return nil
        }
        
        self.score = score
        self.created = created
        self.author = author
        self.body = body
        
        if let replies = JSONData["replies"] as? NSDictionary {
            self.replies = CommentsParser().parseItems(json: [replies], inner: true)
        }
        super.init()
    }
}
