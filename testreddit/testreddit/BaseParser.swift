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
    
    //MARK: - Enums and Constants
    
    /// Data types in reddit.
    ///
    /// - THING: a post
    /// - COMMENT: a comment for post
    /// - LISTING: a list of smth
    public enum RedditTypes: String {
        case THING = "t3"
        case COMMENT = "t1"
        case LISTING = "Listing"
    }
    
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
    /// - Returns: a dictionary of items and the anchor to the last item (can be nil)
    func getItems(json: JSON, inner: Bool = false) -> (JSON?, String?) {
        let kind = inner ? json[1][BaseParser.KIND_KEY].stringValue : json[BaseParser.KIND_KEY].stringValue
        
        guard kind == RedditTypes.LISTING.rawValue else {
            return (nil, nil)
        }
        guard let items = inner ? json[1][BaseParser.DATA_KEY].dictionary : json[BaseParser.DATA_KEY].dictionary else {
            return (nil, nil)
        }
        
        let itemsArray = items[BaseParser.CHILDREN_KEY]
        let after = items[BaseParser.AFTER_KEY]?.string
        return (itemsArray, after)
    }
    
    
    /// Gets a dictionary with item data.
    ///
    /// - Parameters:
    ///   - item: item data with wrapping
    ///   - type: type of item needed
    /// - Returns: an optinal dictionaty with the item itself
    func getItemData(item: JSON, type: RedditTypes) -> JSON? {
        let itemKind = item[BaseParser.KIND_KEY].stringValue
        guard itemKind == type.rawValue else {
            return nil
        }
        let itemData = item[BaseParser.DATA_KEY]
        return itemData
    }
}
