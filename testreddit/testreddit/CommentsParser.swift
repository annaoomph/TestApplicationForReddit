//
//  CommentsParser.swift
//  testreddit
//
//  Created by Alexander on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation


/// Parses comments from the server.
class CommentsParser: BaseParser {
    
    
    /// Parses a json with comments to some post.
    ///
    /// - Parameters:
    ///   - json: json string
    ///   - inner: if this is the inner list of comments connected to some other comment or this is the top of the comments tree
    /// - Returns: an optional list of comments
    func parseItems(json: [NSDictionary], inner: Bool) -> [Comment]? {
        var comments: [Comment] = []
        
        let (items, afterLink) = getItems(json: json)
        
        if let after = afterLink {
            PostsParser.LAST_POST = after
        }
        guard let itemsArray = items else {
            return nil
        }
        
        for item: NSDictionary in itemsArray {
            guard let itemData = getItemData(item: item, type: .COMMENT) else {
                continue
            }
            if let comment = Comment(JSONData: itemData) {
                comments.append(comment)
            }            
        }
        return comments
    }
}
