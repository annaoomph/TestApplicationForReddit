//
//  BaseSession.swift
//  testreddit
//
//  Created by Alexander on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}


/// A session making requests to server (base class).
public class BaseSession: TokenDelegate {
    
    //MARK: - Properties
    var closure: (_ json: [NSDictionary]? , _ error: String?) -> Void = {a, b in }
    var savedUrl: URL?
    var savedHttpMethod: HTTPMethod?
    private static let APP_ONLY_USERNAME = "K75CEraOnGf3iw"
    //MARK: - Request Methods
    
    
    /// Tries to make a request (checks the token first).
    ///
    /// - Parameters:
    ///   - checkToken: whether to check the token
    ///   - url: url to api
    ///   - authorization: authorization header string (token or username/pass)
    ///   - httpMethod: method for retrieving data
    ///   - body: body (if needed, can be nil)
    ///   - callback: delegate
    func makeRequest(checkToken: Bool = true, url: URL, authorization: String?, httpMethod: HTTPMethod, body: [String: String]? = nil, callback: @escaping (_ json: [NSDictionary]? , _ error: String?) -> Void) {
        if checkToken, TokenSession.tokenExpired() {
            closure = callback
            savedUrl = url
            savedHttpMethod = httpMethod
            
            TokenSession().updateToken(callback: self)
        } else {
            performRequest(url: url, authorization: authorization, httpMethod: httpMethod, body: body, callback: callback)
        }
    }
    
    
    /// Performs the requeast itself (no checking, just the request).
    ///
    /// - Parameters:
    ///   - url: url to api
    ///   - authorization: auth header
    ///   - httpMethod: method for the request
    ///   - body: optional parameter body
    ///   - callback: delegate
    private func performRequest(url: URL, authorization: String?, httpMethod: HTTPMethod, body: [String: String]? = nil, callback: @escaping (_ json: [NSDictionary]? , _ error: String?) -> Void) {
        var request = URLRequest(url:url)
        
        request.httpMethod = httpMethod.rawValue
        
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("User-Agent: ios:testredditapp (by /u/annaoomph", forHTTPHeaderField: "User-Agent")
        
        if httpMethod == .post, let bodyArray = body {
            let bodyString = getBodyString(body: bodyArray)
            request.httpBody = bodyString.data(using: String.Encoding.utf8)
        }
        
        if let authValue = authorization {
            request.setValue(authValue, forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                callback(nil, error?.localizedDescription)
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary {
                    callback([json], nil)
                } else if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [NSDictionary] {
                    callback(json, nil)
                }
            } catch {
                callback(nil, "Parse error.")
            }
        }
        task.resume()
    }
    
    //MARK: - TokenDelegate Methods
    public func onNewTokenReceived(newToken token: Token) {
        performRequest(url: savedUrl!, authorization: token.access_token, httpMethod: savedHttpMethod!, callback: closure)
    }
    
    public func onTokenError(error: String) {
        closure(nil, error)
    }
    
    //MARK: - Additional getters
    
    /// Get the body string from the given array of parameters.
    ///
    /// - Parameter body: array of parameters
    /// - Returns: body string
    func getBodyString(body: [String: String]) -> String {
        var bodyString = ""
        for (key, value) in body {
            let parameter = "\(key)=\(value)&"
            bodyString.append(parameter)
        }
        
        bodyString.remove(at: bodyString.index(before: bodyString.endIndex))
        return bodyString
    }
    
    
    /// Gets the authorization string for getting the token (app only athorization).
    ///
    /// - Returns: header auth string
    func getAuthorizationString() -> String {
        let username = BaseSession.APP_ONLY_USERNAME
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
