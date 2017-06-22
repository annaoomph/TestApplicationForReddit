//
//  TokenDelegate.swift
//  testreddit
//
//  Created by Alexander on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation


/// A delegate for getting token from server.
public protocol TokenDelegate {
    
    
    /// Called when the app received the token value from server and saved it.
    ///
    /// - Parameter token: token object.
    func onNewTokenReceived(newToken token:Token)
    
    
    /// Called when an error occurred.
    ///
    /// - Parameter error: a string descriving an error
    func onTokenError(error: String)
}
