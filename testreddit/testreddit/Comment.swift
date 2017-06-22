//
//  Comment.swift
//  testreddit
//
//  Created by Alexander on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

public class Comment: NSObject {
    var score: Int
    var created: Int
    var author: String
    var body: String
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
