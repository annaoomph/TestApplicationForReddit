//
//  BaseParser.swift
//  testreddit
//
//  Created by Alexander on 6/22/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Parses json data from reddit.
class BaseParser {
    
    static let KIND_KEY = "kind"
    static let DATA_KEY = "data"
    static let CHILDREN_KEY = "children"
    static let AFTER_KEY = "after"
    
    //MARK: - Parser functions
    
    /// Gets a dictionary of items of some kind.
    ///
    /// - Parameters:
    ///   - json: json string
    ///   - inner: if this is an inner dictionary
    /// - Returns: a dictionary of items
    func getItems(json: JSON, inner: Bool = false) -> (JSON?) {
        let kind = inner ? json[1][BaseParser.KIND_KEY].stringValue : json[BaseParser.KIND_KEY].stringValue
        
        guard kind == RedditType.LISTING.rawValue else {
            return (nil)
        }
        let items = inner ? json[1][BaseParser.DATA_KEY][BaseParser.CHILDREN_KEY] : json[BaseParser.DATA_KEY][BaseParser.CHILDREN_KEY] 
        
        return items
    }
    
    
    /// Gets a dictionary with item data.
    ///
    /// - Parameters:
    ///   - item: item data with wrapping
    ///   - type: type of item needed
    /// - Returns: an optinal dictionaty with the item itself
    func getItemData(item: JSON, type: RedditJsonType) -> JSON? {
        let itemKind = item[BaseParser.KIND_KEY].stringValue
        guard itemKind == type.rawValue else {
            return nil
        }
        let itemData = item[BaseParser.DATA_KEY]
        return itemData
    }
}
