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
    static let ACCEPTED_TOKEN_TYPE = "bearer"
    
    var body = ["grant_type" : "", "device_id" : ""]
    
    func updateToken(callback: TokenDelegate? = nil, forceRefresh: Bool = false) {
        if forceRefresh || TokenSession.tokenExpired() {
            let url = URL(string: TokenSession.TOKEN_URL);
            
            body["grant_type"] = TokenSession.GRANT_TYPE_VALUE
            body["device_id"] = NSUUID().uuidString;
            
            makeRequest(checkToken: false, url: url!, authorization: getAuthorizationString(), httpMethod: .post, body: body, callback: {json, errString in
                if let error = errString {
                    if let delegate = callback {
                        delegate.onTokenError(error: error)
                    }
                } else {
                    if let dictionary = json {
                        let token = Token()
                        if token.initWithJson(dictionary as! [AnyHashable : Any]) {
                            if token.token_type == TokenSession.ACCEPTED_TOKEN_TYPE {
                                PreferenceManager().saveToken(token: token.access_token)
                                var expirationDate = Date()
                                expirationDate.addTimeInterval(TimeInterval(Int(token.expires_in)))
                                PreferenceManager().saveTokenExpirationDate(date: Int(expirationDate.timeIntervalSince1970))
                                if let delegate = callback {
                                    delegate.onNewTokenReceived(newToken: token)
                                }
                            }
                        } else {
                            if let delegate = callback {
                                delegate.onTokenError(error: "Could not retrieve token!")
                            }
                        }
                    }
                }
            })
        }
    }
    
    class func tokenExpired() -> Bool {
        let expirationDate = PreferenceManager().getTokenExpirationDate()
        let date = Date(timeIntervalSince1970: TimeInterval(expirationDate))
        return date < Date()
    }
    
}
