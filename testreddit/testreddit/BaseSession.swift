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

public class BaseSession: TokenDelegate {
    
    var closure: (_ json: NSDictionary? , _ error: String?) -> Void = {a, b in }
    var savedUrl: URL?
    var savedHttpMethod: HTTPMethod?
    
    func makeRequest(checkToken: Bool = true, url: URL, authorization: String?, httpMethod: HTTPMethod, body: [String: String]? = nil, callback: @escaping (_ json: NSDictionary? , _ error: String?) -> Void) {
        if checkToken, TokenSession.tokenExpired() {
            closure = callback
            savedUrl = url
            savedHttpMethod = httpMethod
            
            TokenSession().updateToken(callback: self)
        } else {
            performRequest(url: url, authorization: authorization, httpMethod: httpMethod, body: body, callback: callback)
        }
    }
    
    private func performRequest(url: URL, authorization: String?, httpMethod: HTTPMethod, body: [String: String]? = nil, callback: @escaping (_ json: NSDictionary? , _ error: String?) -> Void) {
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
                    callback(json, nil)
                }
            } catch {
                callback(nil, "Parse error.")
            }
        }
        task.resume()
    }
    
    public func onNewTokenReceived(newToken token: Token) {
        performRequest(url: savedUrl!, authorization: getToken(), httpMethod: savedHttpMethod!, callback: closure)
    }
    
    public func onTokenError(error: String) {
        closure(nil, error)
    }
    
    func getBodyString(body: [String: String]) -> String {
        var bodyString = ""
        for (key, value) in body {
            let parameter = "\(key)=\(value)&"
            bodyString.append(parameter)
        }
        
        bodyString.remove(at: bodyString.index(before: bodyString.endIndex))
        return bodyString
    }
    
    func getAuthorizationString() -> String {
        let username = "K75CEraOnGf3iw"
        let password = ""
        let loginString = NSString(format: "%@:%@", username, password)
        let loginData: NSData = loginString.data(using: String.Encoding.utf8.rawValue)! as NSData
        let base64LoginString = loginData.base64EncodedString(options: NSData.Base64EncodingOptions())
        return "Basic \(base64LoginString)"
    }
    
    func getToken() -> String {
        return "Bearer \(PreferenceManager().getToken())"
    }
}
