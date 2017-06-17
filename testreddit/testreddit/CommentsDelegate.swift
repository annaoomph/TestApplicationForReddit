//
//  CommentsDelegate.swift
//  testreddit
//
//  Created by Alexander on 6/17/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

protocol CommentsDelegate {
    func onCommentsDelivered(comments: [Comment])
    func onError(error: String)
}
