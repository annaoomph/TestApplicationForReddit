//
//  Parser.swift
//  testreddit
//
//  Created by Anna on 6/15/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Parses posts from server.
class PostsParser: BaseParser {
    
    /// Defines whether the database is cleared (needs to be cleared one time before inserting any items).
    var dbCleared = false
    
    /// Parses a json with posts (links).
    ///
    /// - Parameter json: json string from server in JSON format.
    /// - Parameter clearDb whether the previous database needs to be cleared.
    /// - Returns: an optional array of links (posts).
    func parseItems(json: JSON, clearDb: Bool = false) -> [LinkM]? {
        var links: [LinkM] = []
        
        let items = getItems(json: json)
        
        guard let itemsArray = items else {
            return (nil)
        }
        
        for (_, item) in itemsArray {
            
            guard let itemData = getItemData(item: item, type: RedditJsonType.THING) else {
                continue
            }
            if clearDb, !dbCleared {
                dbCleared = true
                CoreDataManager.instance.clear()
            }
            if let link = LinkM.create(JSONData: itemData) {
                links.append(link)
            }
        }
        return (links)
    }
}
