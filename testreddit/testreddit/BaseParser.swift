//
//  BaseParser.swift
//  testreddit
//
//  Created by Anna on 6/22/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Parses json data from reddit.
class BaseParser {
    
    /// Keys for json dictionary that should come from reddit server.
    struct ParseKeys {
        static let KIND_KEY = "kind"
        static let DATA_KEY = "data"
        static let CHILDREN_KEY = "children"
        static let AFTER_KEY = "after"
    }
    
    //MARK: - Parser functions
    
    /// Gets a dictionary of items of some kind.
    ///
    /// - Parameters:
    ///   - json: json object.
    ///   - inner: whether this is an inner dictionary (useful when parsing comment trees).
    /// - Returns: a dictionary of items.
    func getItems(json: JSON, inner: Bool = false) -> JSON? {
        let kind = inner ? json[1][BaseParser.ParseKeys.KIND_KEY].stringValue : json[BaseParser.ParseKeys.KIND_KEY].stringValue
        //The type of the initial json should be a listing.
        guard kind == RedditJsonType.LISTING.rawValue else {
            return nil
        }
        //The dictionary of items itself is placed upon [data][children]. No check for nil because the fuction returns nullable.
        let items = inner ? json[1][BaseParser.ParseKeys.DATA_KEY][BaseParser.ParseKeys.CHILDREN_KEY] : json[BaseParser.ParseKeys.DATA_KEY][BaseParser.ParseKeys.CHILDREN_KEY]
        
        return items
    }
    
    
    /// Gets a dictionary with item data.
    ///
    /// - Parameters:
    ///   - item: item data in json wrapping.
    ///   - type: type of item needed.
    /// - Returns: an optinal dictionaty with the item itself.
    func getItemData(item: JSON, type: RedditJsonType) -> JSON? {
        let itemKind = item[BaseParser.ParseKeys.KIND_KEY].stringValue
        //Check if this is the item of the kind we need.
        guard itemKind == type.rawValue else {
            return nil
        }
        //The item itself is placed upon [data].
        let itemData = item[BaseParser.ParseKeys.DATA_KEY]
        return itemData
    }
}
