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
    
    /// A service that makes actual requests to the server.
    let webService: WebService
    
    init() {
        webService = WebService()
    }
    
    /// Sends user to authorization screen where he can allow the needed permissions.
    static func authorizeUser() {
        if let url = URL(string: WebUtils.constructUrl(baseUrl: Configuration.AUTH_URL, with:
            ["client_id" : Configuration.APP_ONLY_USERNAME,
             "response_type" : "token",
             "state" : "test",
             "redirect_uri" : Configuration.REDIRECT_URI,
             "scope" : Configuration.SCOPES])) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    /// If the user chooses to allow application, handle the redirected response.
    ///
    /// - Parameter url: redirected url.
    /// - Returns: true if the response is successful and contains token, false otherwise.
    static func handleAuthorizationResponseWith(_ url: URL) -> Bool {
        if url.scheme == Configuration.APP_SCHEME {
            if let token = WebUtils.retrieveTokenFromResponse(url.absoluteString) {
                PreferenceManager().userAuthorized(authorized: true)
                PreferenceManager().saveToken(token: token.access_token)
                var expirationDate = Date()
                expirationDate.addTimeInterval(TimeInterval(Int(token.expires_in)!))
                PreferenceManager().saveTokenExpirationDate(date: Int(expirationDate.timeIntervalSince1970))
                return true
            }
        }
        return false
    }
    
    /// Tries to update the token value if needed and returns the actual value in a callback.
    ///
    /// - Parameters:
    ///   - pendingRequest: a request waiting to be executed, needs a valid token value to proceed with execution.
    private func getToken(pendingRequest: @escaping (_ token: String?, _ error: Error?) -> Void) {
        if WebUtils.tokenExpired() {
            let url = URL(string: Configuration.TOKEN_URL)
            var body : [String:String]
            body = ["grant_type" : Configuration.GRANT_TYPE_VALUE, "device_id" : NSUUID().uuidString]
        
            webService.makeRequestTo(url!, authorizedWith: WebUtils.getAuthorizationString(), using: .post, with: body) {
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
                                        pendingRequest(WebUtils.getToken(), nil)
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
    ///   - more: if the request for loading more posts was made.
    ///   - callback: delegate.
    func getPostsOfType(_ type: ContentType.PostType, more: Bool = false, callback: @escaping (_ posts: [LinkM]?, _ error: Error?) -> Void) {
        var urlString = WebUtils.getPostUrlFor(type)
        urlString = more ? WebUtils.constructUrl(baseUrl: urlString, with: ["after" : "t3_\(WebUtils.getLastPostAnchor())"]) : urlString
        let url = URL(string: urlString)
        makeGetRequestTo(url!, for: .POSTS, withParameter: !more, callback: callback, parseFunction: PostsParser().parseItems(json:clearDb:))
    }
    
    /// Requests a list of comments for a certain post.
    ///
    /// - Parameters:
    ///   - postId: id of the post (link).
    ///   - callback: delegate.
    func getCommentsForPostWithId(_ postId: String,  callback: @escaping (_ comments: [Comment]? , _ error: Error?) -> Void) {
        let url = URL(string: "\(Configuration.COMMENTS_URL)\(postId)")
        makeGetRequestTo(url!, for: .COMMENTS, withParameter: true, callback: callback, parseFunction: CommentsParser().parseItems(json:inner:))
    }
    
    
    /// Makes a get request, parses it with the given function and returns the result to the given callback.
    ///
    /// - Parameters:
    ///   - url: url to make request to.
    ///   - type: type of the data.
    ///   - additionalParameter: additional parsing parameter.
    ///   - callback: callback for result of the request.
    ///   - parseFunction: a function for parsing data.
    func makeGetRequestTo<T>(_ url: URL, for type: ContentType, withParameter additionalParameter: Bool, callback: @escaping (_ items: [T]? , _ error: Error?) -> Void, parseFunction: @escaping (_ json: JSON, _ additionalParameter: Bool) -> [T]?) {
        getToken {
            token, error in
            if let appToken = token {
                self.webService.makeRequestTo(url, authorizedWith: appToken, using: .get) {
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
