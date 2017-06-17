//
//  CommentsParser.swift
//  testreddit
//
//  Created by Alexander on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
public class CommentsParser {
    func parseItems(json: [NSDictionary], inner: Bool) -> [Comment]? {
        var comments: [Comment] = []
        
        guard let kind = json[inner ? 0 : 1]["kind"] as! String? else {
            return nil
        }
        guard kind == "Listing" else {
            return nil
        }
        guard let items = json[inner ? 0 : 1]["data"] as! NSDictionary? else {
            return nil
        }
        guard let itemsArray = items["children"] as! [NSDictionary]? else {
            return nil
        }
        for item: NSDictionary in itemsArray {
            guard let itemKind = item["kind"] as! String? else {
                continue
            }
            guard itemKind == "t1" else {
                continue
            }
            guard let itemData = item["data"] as! NSDictionary? else {
                continue
            }
            if let comment = Comment(JSONData: itemData) {
                comments.append(comment)
            }
            
        }
        return comments
    }
}
