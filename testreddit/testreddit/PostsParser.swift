//
//  Parser.swift
//  testreddit
//
//  Created by Alexander on 6/15/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation


/// Parses json data from reddit.
class PostsParser: BaseParser {
    
    
    /// Anchor to the last loaded post (its id) to load more posts after it.
    static var LAST_POST: String?
    
    
    /// Parses a json with posts (links).
    ///
    /// - Parameter json: json string from server
    /// - Returns: an optional array of links (posts)
    func parseItems(json: [NSDictionary]) -> [LinkM]? {
        var links: [LinkM] = []
        
        let (items, afterLink) = getItems(json: json)
        
        if let after = afterLink {
            PostsParser.LAST_POST = after
        }
        guard let itemsArray = items else {
            return nil
        }
        
        for item: NSDictionary in itemsArray {
            guard let itemData = getItemData(item: item, type: .THING) else {
                continue
            }
            if let link = LinkM.create(JSONData: itemData) {
                links.append(link)
            }
            
        }
        return links
    }
}
