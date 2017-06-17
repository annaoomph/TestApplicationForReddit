//
//  Parser.swift
//  testreddit
//
//  Created by Alexander on 6/15/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

class Parser {
    static var LAST_POST: String?
    
    func parseItems(json: NSDictionary) -> [Link]? {
        var links: [Link] = []
        guard let kind = json["kind"] as! String? else {
            return nil
        }
        guard kind == "Listing" else {
            return nil
        }
        guard let items = json["data"] as! NSDictionary? else {
            return nil
        }
        guard let itemsArray = items["children"] as! [NSDictionary]? else {
            return nil
        }
        if let after = items["after"] as! String? {
                Parser.LAST_POST = after
        }
        for item: NSDictionary in itemsArray {
            guard let itemKind = item["kind"] as! String? else {
                continue
            }
            guard itemKind == "t3" else {
                continue
            }
            guard let itemData = item["data"] as! NSDictionary? else {
                continue
            }
            if let link = Link(JSONData: itemData) {
                links.append(link)
            }
            
        }
        return links
    }
}
