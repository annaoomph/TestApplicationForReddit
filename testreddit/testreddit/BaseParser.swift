//
//  BaseParser.swift
//  testreddit
//
//  Created by Alexander on 6/22/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

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
    func getItems(json: [NSDictionary], inner: Bool = true) -> ([NSDictionary]?, String?) {
        guard let kind = json[inner ? 0 : 1][BaseParser.KIND_KEY] as! String? else {
            return (nil, nil)
        }
        guard kind == RedditTypes.LISTING.rawValue else {
            return (nil, nil)
        }
        guard let items = json[inner ? 0 : 1][BaseParser.DATA_KEY] as! NSDictionary? else {
            return (nil, nil)
        }
        guard let itemsArray = items[BaseParser.CHILDREN_KEY] as! [NSDictionary]? else {
            return (nil, nil)
        }
        let after = items[BaseParser.AFTER_KEY] as? String
        return (itemsArray, after)
    }
    
    
    /// Gets a dictionary with item data.
    ///
    /// - Parameters:
    ///   - item: item data with wrapping
    ///   - type: type of item needed
    /// - Returns: an optinal dictionaty with the item itself
    func getItemData(item: NSDictionary, type: RedditTypes) -> NSDictionary? {
        guard let itemKind = item[BaseParser.KIND_KEY] as! String? else {
            return nil
        }
        guard itemKind == type.rawValue else {
            return nil
        }
        guard let itemData = item[BaseParser.DATA_KEY] as! NSDictionary? else {
            return nil
        }
        return itemData
    }
}
