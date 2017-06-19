//
//  DatabaseManager.swift
//  testreddit
//
//  Created by Alexander on 6/19/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
protocol DatabaseManager {
 
    func getAllPosts() -> [Link]?
    func deleteAllPosts() -> Bool
    func savePosts(posts: [Link]) -> Bool
}
