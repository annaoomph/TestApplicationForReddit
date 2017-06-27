//
//  WebService.swift
//  testreddit
//
//  Created by Alexander on 6/23/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}


/// Makes requests to server.
class WebService {
    
    /// Performs the requeast itself (no checking, just the request).
    ///
    /// - Parameters:
    ///   - url: url to api
    ///   - authorization: auth header
    ///   - httpMethod: method for the request
    ///   - body: optional parameter body
    ///   - callback: delegate
    func makeRequest(url: URL, authorization: String?, httpMethod: HTTPMethod, body: [String: String]? = nil, callback: @escaping (_ json: Data?, _ error: String?) -> Void) {
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
                callback(data, nil)
            } catch {
                callback(nil, "Parse error.")
            }
        }
        task.resume()
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
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

}
