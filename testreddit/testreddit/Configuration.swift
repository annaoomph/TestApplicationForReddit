//
//  Configuration.swift
//  testreddit
//
//  Created by Anna on 6/23/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import UIKit

/// Some constants used in all application.
class Configuration {

    // MARK: - Urls
    static let BASE_OAUTH_URL = "https://oauth.reddit.com/"
    static let BASE_REDDIT_API_URL = "https://www.reddit.com/api/v1/"
    static let HOT_POSTS_URL = BASE_OAUTH_URL.appending("hot")
    static let NEW_POSTS_URL = BASE_OAUTH_URL.appending("new")
    static let COMMENTS_URL = BASE_OAUTH_URL.appending("comments/")
    static let TOKEN_URL = BASE_REDDIT_API_URL.appending("access_token")
    static let AUTH_URL = BASE_REDDIT_API_URL.appending("authorize")
    
    // MARK: - Authorization constants
    static let APP_ONLY_USERNAME = "K75CEraOnGf3iw"
    static let GRANT_TYPE_VALUE = "https://oauth.reddit.com/grants/installed_client"
    static let GRANT_TYPE_VALUE_USER_AUTH = "refresh_token"
    static let ACCEPTED_TOKEN_TYPE = "bearer"
    static let APP_SCHEME = "testreddit"
    static let REDIRECT_URI = APP_SCHEME.appending("://response")
    static let SCOPES = "read"
    
    // MARK: - Strings
    static let USER_AUTH_QUESTION = "It seems that you are not authorized under any user. You can continue browsing anonimously or log into your account. Would you like to log in now?"
    static let USER_AUTH_OPTIONS = ["Yes, authorize me!", "Don't ask me again", "Thanks, I'll do it later"]
    
    // MARK: - Application Colors
    struct Colors {
        static let red = UIColor(red: 251/255, green: 61/255, blue: 13/255, alpha: 1)
        static let blue = UIColor(red: 100/255, green: 180/255, blue: 240/255, alpha: 1)
        static let green = UIColor(red: 135/255, green: 234/255, blue: 162/255, alpha: 1)
        static let orange = UIColor(red: 255/255, green: 106/255, blue: 5/255, alpha: 1)
    }
}
