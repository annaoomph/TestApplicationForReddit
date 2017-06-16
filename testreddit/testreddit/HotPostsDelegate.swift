//
//  HotPostsDelegate.swift
//  testreddit
//
//  Created by Alexander on 6/15/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

protocol HotPostsDelegate {
    func onPostsDelivered(posts: [Link])
    func onError(error: String)
}
