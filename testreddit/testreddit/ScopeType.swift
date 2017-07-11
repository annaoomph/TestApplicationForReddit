//
//  ScopeType.swift
//  testreddit
//
//  Created by Alexander on 7/11/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation


/// List of all scope sorting types. Used in controller when performing a search on posts.
///
/// - All: All posts.
/// - Other: Posts that don't contain an image or a gif (usually plain text or a link to an external resourse)
/// - Image: Posts that contain image
/// - Gif: Posts that contain gif
enum ScopeType: String {
    case All
    case Other
    case Image
    case Gif
}
