//
//  ContentType.swift
//  testreddit
//
//  Created by Alexander on 6/30/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

enum ContentType: String {
    case POSTS = "posts"
    
    enum PostType: String {
        case NEW = "New Posts"
        case HOT = "Hot Posts"
        static func getPostType(selectedTab: Int) -> PostType {
            if selectedTab == 0 {
                return .HOT
            } else {
                return .NEW
            }
        }
    }
    
    case COMMENTS = "comments"
}
