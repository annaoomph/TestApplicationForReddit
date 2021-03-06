//
//  UrlUtils.swift
//  testreddit
//
//  Created by Anna on 6/29/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// Utils for networking.
class WebUtils {
    
    /// Constructs the url from its base and with parameters dictionary.
    ///
    /// - Parameters:
    ///   - base: base url.
    ///   - parameters: a dictionary with parameters.
    /// - Returns: url string.
    static func constructUrl(baseUrl base: String, with parameters: [String: String]) -> String {
        var mainPart = base
        mainPart.append("?")
        mainPart.append(getParameterStringFor(parameters))
        return mainPart
    }
    
    /// Gets the token value from redirected url. Parses the query parameters for the URI.
    ///
    /// - Parameter response: response which can possibly contain the token, if user has given all the permissions.
    /// - Returns: token, if present, and its expiration date.
    static func retrieveTokenFromResponse(_ response: String) -> (access_token: String, expires_in: String)? {
        let responseArray = response.components(separatedBy: ["&", "#"])
        var token: String?
        var expiresIn: String?
        for responseElement in responseArray {
            if responseElement.hasPrefix("access_token") {
                token = responseElement.components(separatedBy: ["="])[1]
            }
            if responseElement.hasPrefix("expires_in") {
                expiresIn = responseElement.components(separatedBy: ["="])[1]
            }
        }
        guard let retrievedToken = token, let retrievedExpiration = expiresIn else {
            return nil
        }
        return (access_token: retrievedToken, expires_in: retrievedExpiration)
    }
    
    /// Gets a string with parameters from the given dictionary.
    ///
    /// - Parameter parameters: parameters dictionary.
    /// - Returns: built string.
    static func getParameterStringFor(_ parameters: [String: String]) -> String {
        var parameterString = ""
        for (key, value) in parameters {
            parameterString.append("\(key)=\(value)&")
        }
        parameterString.remove(at: parameterString.index(before: parameterString.endIndex))
        return parameterString
    }
    
    /// Gets the url to post depending on its type.
    ///
    /// - Parameter postType: type of the post (see enum).
    /// - Returns: url string.
    static func getPostUrlFor(_ postType: ContentType.PostType) -> String {
        switch postType {
        case .NEW:
            return Configuration.NEW_POSTS_URL
        case .HOT:
            return Configuration.HOT_POSTS_URL
        }
    }
    
    /// Gets the authorization string for getting the token (app only athorization).
    ///
    /// - Returns: header auth string.
    static func getAuthorizationString() -> String {
        let username = Configuration.APP_ONLY_USERNAME
        let password = ""
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        return "Basic \(base64LoginString)"
    }
    
    /// Gets the token from preferences.
    ///
    /// - Returns: header auth string with token.
    static func getToken() -> String {
        return "Bearer \(PreferenceManager().getToken())"
    }
    
    /// Checks if the current token has expired.
    ///
    /// - Returns: true if it needs to be refreshed, false otherwise.
    static func tokenExpired() -> Bool {
        let expirationDate = PreferenceManager().getTokenExpirationDate()
        let date = Date(timeIntervalSince1970: TimeInterval(expirationDate - 60))
        return date < Date()
    }
    
    /// Gets the anchor to the last post (to load posts after it).
    ///
    /// - Returns: post anchor <kind_id>.
    static func getLastPostAnchor() -> String {
        return CoreDataManager.instance.getLastPostId() ?? ""
    }
}
