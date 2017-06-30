//
//  Parser.swift
//  testreddit
//
//  Created by Alexander on 6/15/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SwiftyJSON


/// Parses json data from reddit.
class PostsParser: BaseParser {    
    
    /// A parameter indicating whether the database is alredy cleared.
    var dbCleared = false
    
    /// Parses a json with posts (links).
    ///
    /// - Parameter json: json string from server
    /// - Returns: an optional array of links (posts) and the last loaded post id
    func parseItems(json: JSON, clearDb: Bool = false) -> ([LinkM]?) {
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
                CoreDataManager.instance.clear()
                dbCleared = true
            }
            if let link = LinkM.create(JSONData: itemData) {
                links.append(link)
            }
        }
        return (links)
    }
}
