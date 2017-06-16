//
//  PreferenceManager.swift
//  testreddit
//
//  Created by Alexander on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

public class PreferenceManager {
    var preferences: UserDefaults
    static let TOKEN_KEY = "token"
    static let EXPIRATION_DATE_KEY = "expiration"
    static let DB_INITIALIZED_KEY = "init"
    
    init() {
        preferences = UserDefaults.standard
    }
    
    func saveToken(token: String) {
        preferences.set(token, forKey: PreferenceManager.TOKEN_KEY)
    }
    
    func saveTokenExpirationDate(date: Int) {
        preferences.set(date, forKey: PreferenceManager.EXPIRATION_DATE_KEY)
    }
    
    func getTokenExpirationDate() -> Int {
        if let date = preferences.object(forKey: PreferenceManager.EXPIRATION_DATE_KEY) as! Int? {
            return date
        }
        return 0
    }
    
    func getToken() -> String {
        if let tokenString = preferences.object(forKey: PreferenceManager.TOKEN_KEY) as! String? {
            return tokenString
        }
        return ""
    }
    
    func setDbInitialized() {
        preferences.set(true, forKey: PreferenceManager.DB_INITIALIZED_KEY)
    }
    
    func dbInitialized() -> Bool {
        if let initialized = preferences.object(forKey: PreferenceManager.DB_INITIALIZED_KEY) as! Bool? {
            return initialized
        }
        return false
    }
}
