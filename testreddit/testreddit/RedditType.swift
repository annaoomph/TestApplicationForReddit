//
//  RedditType.swift
//  testreddit
//
//  Created by Anna on 6/30/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// A list of json data types coming from reddit. Helps to parse json dictionaries.
///
/// - THING: a post (or link)
/// - COMMENT: a comment to a post
/// - LISTING: a list of smth
public enum RedditJsonType: String {
    case THING = "t3"
    case COMMENT = "t1"
    case LISTING = "Listing"
}
