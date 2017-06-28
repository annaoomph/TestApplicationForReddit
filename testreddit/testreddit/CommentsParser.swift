//
//  CommentsParser.swift
//  testreddit
//
//  Created by Alexander on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Parses comments from the server.
class CommentsParser: BaseParser {
    
    /// Parses a json with comments to some post.
    ///
    /// - Parameters:
    ///   - json: json string
    ///   - inner: if this is the inner list of comments connected to some other comment or this is the top of the comments tree
    /// - Returns: an optional list of comments
    func parseItems(json: JSON, inner: Bool) -> [Comment]? {
        var comments: [Comment] = []
        
        let (items, _) = getItems(json: json, inner: inner)
        
        guard let itemsArray = items else {
            return nil
        }
        
        for (_, item) in itemsArray {
            guard let itemData = getItemData(item: item, type: RedditTypes.COMMENT) else {
                continue
            }
            if let comment = Comment(JSONData: itemData) {
                comments.append(comment)
            }
        }
        
        return comments
    }
}
