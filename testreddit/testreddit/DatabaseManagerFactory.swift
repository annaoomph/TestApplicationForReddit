//
//  DatabaseManagerFactory.swift
//  testreddit
//
//  Created by Alexander on 6/19/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
public class DatabaseManagerFactory {
    class func getDatabaseManager() -> DatabaseManager {
        return SqliteDatabaseManager()
    }
}
