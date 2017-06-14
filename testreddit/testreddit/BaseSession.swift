//
//  BaseSession.swift
//  testreddit
//
//  Created by Alexander on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

public class BaseSession {
    
    func makePostRequest(url: URL, body: [String: String], callback: @escaping (_ json: NSDictionary) -> Void) {
        
        var request = URLRequest(url:url)
        
        request.httpMethod = "POST"
        
        let bodyString = getBodyString(body: body)
        
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField:     "Content-Type")
        request.addValue("User-Agent: ios:testredditapp (by /u/annaoomph", forHTTPHeaderField: "User-Agent")
        
        request.httpBody = bodyString.data(using: String.Encoding.utf8)        
        
        request.setValue(getAuthorizationString(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary {
                    callback(json)
                }
            } catch {
                return
            }
        }
        task.resume()
    }
    
    func makeGetRequest(url: URL, callback: @escaping (_ json: NSDictionary) -> Void) {
        
        var request = URLRequest(url:url)
        
        request.httpMethod = "GET"
        
        request.addValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField:     "Content-Type")
        request.addValue("User-Agent: ios:testredditapp (by /u/annaoomph", forHTTPHeaderField: "User-Agent")
        
        request.setValue(getToken(), forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if error != nil {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary {
                    callback(json)
                }
            } catch {
                return
            }
        }
        task.resume()
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
