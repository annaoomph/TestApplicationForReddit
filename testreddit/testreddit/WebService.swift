//
//  WebService.swift
//  testreddit
//
//  Created by Anna on 6/23/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// Makes requests to server.
class WebService {
    
    /// Performs the request itself (no checks, just the request).
    ///
    /// - Parameters:
    ///   - url: url to api.
    ///   - authorization: auth header.
    ///   - httpMethod: method for the request.
    ///   - body: optional parameter body.
    ///   - callback: delegate.
    func makeRequestTo(_ url: URL, authorizedWith authorization: String?, using httpMethod: HTTPMethod, with body: [String: String]? = nil, callback: @escaping (_ json: Data?, _ error: Error?) -> Void) {
        var request = URLRequest(url:url)
        
        request.httpMethod = httpMethod.rawValue
        
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("User-Agent: ios:testredditapp (by /u/annaoomph", forHTTPHeaderField: "User-Agent")
        
        if httpMethod == .post, let bodyArray = body {
            let bodyString = WebUtils.getParameterStringFor(bodyArray)
            request.httpBody = bodyString.data(using: String.Encoding.utf8)
        }
        
        if let authValue = authorization {
            request.setValue(authValue, forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                callback(nil, error)
            } else {
                callback(data, nil)
            }
        }
        task.resume()
    }
    
    
    /// Gets an item (such as picture) from url.
    ///
    /// - Parameters:
    ///   - url: path to item.
    ///   - completion: callback.
    func getDataFromUrl(_ url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            completion($0, $1, $2)
            }.resume()
    }

}
