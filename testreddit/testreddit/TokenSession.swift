//
//  TokenOperation.swift
//  testreddit
//
//  Created by Alexander on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

class TokenSession: BaseSession {
    
    static let TOKEN_URL = "https://www.reddit.com/api/v1/access_token"
    static let GRANT_TYPE_VALUE = "https://oauth.reddit.com/grants/installed_client"
    var body = ["grant_type" : "", "device_id" : ""]
    
    func updateToken(callback:TokenDelegate, forceRefresh: Bool = false) {
        var expirationDate = Date()
        expirationDate.addTimeInterval(TimeInterval(PreferenceManager().getTokenExpirationDate()))
        if forceRefresh || expirationDate < Date() {
            let url = URL(string: TokenSession.TOKEN_URL);
            
            body["grant_type"] = TokenSession.GRANT_TYPE_VALUE
            body["device_id"] = NSUUID().uuidString;
            
            makePostRequest(url: url!, body: body, callback: {json in
                let token = Token()
                token.initWithJson(json as! [AnyHashable : Any])
                if token.token_type == "bearer" {
                    callback.onNewTokenReceived(newToken: token)
                }
            })
        }
    }
    
}
