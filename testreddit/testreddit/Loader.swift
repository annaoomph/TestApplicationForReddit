//
//  Loader.swift
//  testreddit
//
//  Created by Alexander on 6/23/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ContentType: String {
    case POSTS = "posts"
    case COMMENTS = "comments"
}

/// Loads data from server and parses it.
class Loader {
    
    let webService: WebService
    
    init() {
        webService = WebService()
    }
    
    /// Tries to update the token value if needed and returns the actual value in a callback.
    ///
    /// - Parameters:
    ///   - pendingRequest: a request waiting to be executed, needs a valid token value to perform execution
    private func getToken(pendingRequest: @escaping (_ token: String?, _ error: Error?) -> Void) {
        if WebUtils.tokenExpired() {
            let url = URL(string: Configuration.TOKEN_URL);
            let body = ["grant_type" : Configuration.GRANT_TYPE_VALUE, "device_id" : NSUUID().uuidString]
            
            webService.makeRequest(url: url!, authorization: WebUtils.getAuthorizationString(), httpMethod: .post, body: body) {
                json, errString in
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
            }
            //If no need to update token (it has not expired), continue executing the callback function with the existing token value.
        } else {
            pendingRequest(WebUtils.getToken(), nil)
        }
    }
    
    
    /// Requests a list of hot posts.
    ///
    /// - Parameters:
    ///   - more: if the request for loading more posts was made
    ///   - callback: delegate
    func getPosts(more: Bool = false, callback: @escaping (_ posts: [LinkM]?, _ error: Error?) -> Void) {
        var urlString = Configuration.POSTS_URL
        urlString = more ? WebUtils.constructUrl(baseUrl: urlString, parameters: ["after" : "t3_\(WebUtils.getLastPostAnchor())"]) : urlString
        let url = URL(string: urlString)
        makeGetRequest(url: url!, type: .POSTS, additionalParameter: !more, callback: callback, parseFunction: PostsParser().parseItems(json:clearDb:))
    }
    
    /// Requests a list of comments for a certain post.
    ///
    /// - Parameters:
    ///   - postId: id of the post (or link)
    ///   - callback: delegate
    func getComments(postId: String,  callback: @escaping (_ comments: [Comment]? , _ error: Error?) -> Void) {
        let url = URL(string: "\(Configuration.COMMENTS_URL)\(postId)")
        makeGetRequest(url: url!, type: .COMMENTS, additionalParameter: true, callback: callback, parseFunction: CommentsParser().parseItems(json:inner:))
    }
    
    
    /// Makes a get request, parses it with the given function and returns the result to the given callback.
    ///
    /// - Parameters:
    ///   - url: url to make request to
    ///   - type: type of the data
    ///   - additionalParameter: additional parsing parameter
    ///   - callback: callback for result of the request
    ///   - parseFunction: a function for parsing data
    func makeGetRequest<T>(url: URL, type: ContentType, additionalParameter: Bool, callback: @escaping (_ items: [T]? , _ error: Error?) -> Void, parseFunction: @escaping (_ json: JSON, _ additionalParameter: Bool) -> [T]?) {
        getToken {
            token, error in
            if let appToken = token {
                self.webService.makeRequest(url: url, authorization: appToken, httpMethod: .get) {
                    json, errString in
                    if let errorResp = error {
                        callback(nil, errorResp)
                    } else {
                        if let dictionary = json {
                            if let items = parseFunction(JSON(data: dictionary), additionalParameter) {
                                if type == .POSTS {
                                    CoreDataManager.instance.saveContext()
                                }
                                callback(items, nil)
                            } else {
                                callback(nil, RedditError.ParseError(type: type.rawValue))
                            }
                        } else {
                            callback(nil, RedditError.LoadError(type: type.rawValue))
                        }
                    }
                }
            } else {
                callback(nil, error)
            }
        }
    }
}
