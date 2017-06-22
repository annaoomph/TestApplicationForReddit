//
//  CommentsDelegate.swift
//  testreddit
//
//  Created by Alexander on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation


/// A delegate for getting comments from the server.
protocol CommentsDelegate {
    
    
    /// Called when a list of comments arrived.
    ///
    /// - Parameter comments: a list of comments.
    func onCommentsDelivered(comments: [Comment])
    
    
    /// Called when error occurred.
    ///
    /// - Parameter error: a string describing the error
    func onError(error: String)
}
