//
//  RedditType.swift
//  testreddit
//
//  Created by Alexander on 6/30/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// Data types in reddit.
///
/// - THING: a post
/// - COMMENT: a comment for post
/// - LISTING: a list of smth
public enum RedditJsonType: String {
    case THING = "t3"
    case COMMENT = "t1"
    case LISTING = "Listing"
}
