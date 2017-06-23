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
    
    /// Parses a json with posts (links).
    ///
    /// - Parameter json: json string from server
    /// - Returns: an optional array of links (posts) and the last loaded post id
    func parseItems(json: [NSDictionary]) -> ([LinkM]?, String?) {
        var links: [LinkM] = []
        
        let (items, afterLink) = getItems(json: json)
        
        guard let itemsArray = items else {
            return (nil, nil)
        }
        
        for item: NSDictionary in itemsArray {
            guard let itemData = getItemData(item: item, type: RedditTypes.THING) else {
                continue
            }
            if let link = LinkM.create(JSONData: itemData) {
                links.append(link)
            }            
        }
        return (links, afterLink)
    }
}
