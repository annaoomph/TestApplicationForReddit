//
//  Configuration.swift
//  testreddit
//
//  Created by Alexander on 6/23/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import UIKit
class Configuration {

    static let TOKEN_URL = "https://www.reddit.com/api/v1/access_token"
    static let POSTS_URL = "https://oauth.reddit.com/hot"
    static let COMMENTS_URL = "https://oauth.reddit.com/comments/"
    static let APP_ONLY_USERNAME = "K75CEraOnGf3iw"
    static let GRANT_TYPE_VALUE = "https://oauth.reddit.com/grants/installed_client"
    static let ACCEPTED_TOKEN_TYPE = "bearer"
    struct Colors {
        static let red = UIColor(red: 251/255, green: 61/255, blue: 13/255, alpha: 1)
        static let blue = UIColor(red: 100/255, green: 180/255, blue: 240/255, alpha: 1)
        static let green = UIColor(red: 135/255, green: 234/255, blue: 162/255, alpha: 1)
        static let orange = UIColor(red: 255/255, green: 106/255, blue: 5/255, alpha: 1)
    }
}
