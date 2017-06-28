//
//  Loader.swift
//  testreddit
//
//  Created by Alexander on 6/23/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Loads data from server and parses it.
class Loader {
    
    let webService: WebService
    
    init() {
        webService = WebService()
    }
    
    
    /// Tries to update the token value if needed.
    ///
    /// - Parameters:
    ///   - pendingRequest: a request waiting to be executed, needs a valid token value to perform execution
    private func updateToken(pendingRequest: @escaping (_ token: String?, _ error: Error?) -> Void) {
        if tokenExpired() {
            let url = URL(string: Configuration.TOKEN_URL);
            let body = ["grant_type" : Configuration.GRANT_TYPE_VALUE, "device_id" : NSUUID().uuidString]
            
            webService.makeRequest(url: url!, authorization: getAuthorizationString(), httpMethod: .post, body: body, callback: {json, errString in
                if let error = errString {
                    pendingRequest(nil, error)
                } else {
                    if let dictionary = json {
                        let token = Token()
                        do {
                            if let jsonDt = try JSONSerialization.jsonObject(with: dictionary, options: .mutableContainers) as? NSDictionary {
                                if token.initWithJson(jsonDt as! [AnyHashable : Any]) {
                                    if token.token_type == Configuration.ACCEPTED_TOKEN_TYPE {
                                        PreferenceManager().saveToken(token: token.access_token)
                                        var expirationDate = Date()
                                        expirationDate.addTimeInterval(TimeInterval(Int(token.expires_in)))
                                        PreferenceManager().saveTokenExpirationDate(date: Int(expirationDate.timeIntervalSince1970))
                                        pendingRequest(token.access_token, nil)
                                    }
                                }
                            } else {
                                pendingRequest(nil, RedditError.LoadError(type: "token"))
                            }
                        } catch {
                             pendingRequest(nil, RedditError.ParseError(type: "token"))
                        }
                        
                    }
                }
            })
            //If no need to update token (it has not expired), continue executing the callback function with the existing token value.
        } else {
            pendingRequest(getToken(), nil)
        }
    }
    
    
    /// Requests a list of hot posts.
    ///
    /// - Parameters:
    ///   - more: if the request for loading more posts was made
    ///   - lastPost: last shown post (can be nil, if more set to false)
    ///   - callback: delegate
    func getPosts(more: Bool = false, lastPost: String? = nil, callback: @escaping (_ posts: [LinkM]?, _ after: String?, _ error: Error?) -> Void) {
        updateToken(pendingRequest: {token, error in
            if let appToken = token {
                var urlString = Configuration.POSTS_URL
                if let parameters = lastPost,
                    more {
                    urlString.append("?after=\(parameters)")
                }
                let url = URL(string: urlString);
                self.webService.makeRequest(url: url!, authorization: appToken, httpMethod: .get, callback: {json, errString in
                    if let error = errString {
                        callback(nil, nil, error)
                    } else {
                        if let dictionary = json {
                            let (items, after) = PostsParser().parseItems(json: JSON(data: dictionary), clearDb: !more)                            
                            if let itemsArray = items {
                                CoreDataManager.instance.saveContext()
                                callback(itemsArray, after, nil)
                            } else {
                                callback(nil, nil, RedditError.ParseError(type: "posts"))
                            }
                            
                        } else {
                            callback(nil, nil, RedditError.LoadError(type: "posts"))
                        }
                    }
                })
            } else { callback(nil, nil, error) }
        })
        
    }
    
    
    /// Requests a list of comments for a certain post.
    ///
    /// - Parameters:
    ///   - postId: id of the post (or link)
    ///   - callback: delegate
    func getComments(postId: String,  callback: @escaping (_ comments: [Comment]? , _ error: Error?) -> Void) {
        updateToken(pendingRequest: {token, error in
            if let appToken = token {
                let url = URL(string: "\(Configuration.COMMENTS_URL)\(postId)");
                self.webService.makeRequest(url: url!, authorization: appToken, httpMethod: .get, callback: {json, errString in
                    if let error = errString {
                        callback(nil, error)
                    } else {
                        if let dictionary = json {
                            if let items = CommentsParser().parseItems(json: JSON(data: dictionary), inner: true) {
                                callback(items, nil)
                            } else {
                                callback(nil, RedditError.ParseError(type: "comments"))
                            }
                        } else {
                            callback(nil, RedditError.LoadError(type: "comments"))
                        }
                    }})
            } else { callback(nil, error) }
            
        })
        
    }
    
    
    /// Checks if the current token has expired.
    ///
    /// - Returns: true if it needs to be refreshed, false otherwise.
    func tokenExpired() -> Bool {
        let expirationDate = PreferenceManager().getTokenExpirationDate()
        let date = Date(timeIntervalSince1970: TimeInterval(expirationDate - 60))
        return date < Date()
    }
    
    
    
    /// Gets the authorization string for getting the token (app only athorization).
    ///
    /// - Returns: header auth string
    func getAuthorizationString() -> String {
        let username = Configuration.APP_ONLY_USERNAME
        let password = ""
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        return "Basic \(base64LoginString)"
    }
    
    
    /// Gets the token from preferences.
    ///
    /// - Returns: header auth string with token
    func getToken() -> String {
        return "Bearer \(PreferenceManager().getToken())"
    }
}
