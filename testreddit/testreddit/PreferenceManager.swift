//
//  PreferenceManager.swift
//  testreddit
//
//  Created by Anna on 6/14/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// Manages User Defaults.
public class PreferenceManager {
    
    var preferences: UserDefaults
    
    init() {
        preferences = UserDefaults.standard
    }
    
    //MARK: - Preferences keys
    static let TOKEN_KEY = "token"
    static let EXPIRATION_DATE_KEY = "expiration"
    static let TAB_KEY = "tab"
    
    //MARK: - Save functions
    
    /// Saves the token value into the user defaults.
    ///
    /// - Parameter token: token value.
    func saveToken(token: String) {
        preferences.set(token, forKey: PreferenceManager.TOKEN_KEY)
    }
    
    /// Save the date when the given token expires.
    ///
    /// - Parameter date: time from 1970, in seconds (TimeInterval).
    func saveTokenExpirationDate(date: Int) {
        preferences.set(date, forKey: PreferenceManager.EXPIRATION_DATE_KEY)
    }
    
    /// Saves the opened tab.
    ///
    /// - Parameter tab: index of the selected tab.
    func saveOpenedTab(tab: Int) {
        preferences.set(tab, forKey: PreferenceManager.TAB_KEY)
    }
    
    //MARK: - Get functions
    
    /// Gets last opened by user tab.
    ///
    /// - Returns: tab index.
    func getLastOpenedTab() -> Int {
        if let tab = preferences.object(forKey: PreferenceManager.TAB_KEY) as! Int? {
            return tab
        }
        return 0
    }
    
    /// Gets the date when the current token expires.
    ///
    /// - Returns: time from 1970, in seconds (TimeInterval).
    func getTokenExpirationDate() -> Int {
        if let date = preferences.object(forKey: PreferenceManager.EXPIRATION_DATE_KEY) as! Int? {
            return date
        }
        return 0
    }
    
    /// Gets the current token value.
    ///
    /// - Returns: token value.
    func getToken() -> String {
        if let tokenString = preferences.object(forKey: PreferenceManager.TOKEN_KEY) as! String? {
            return tokenString
        }
        return ""
    }
}
