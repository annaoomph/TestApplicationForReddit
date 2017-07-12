//
//  ErrorHandler.swift
//  testreddit
//
//  Created by Anna on 6/28/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// A list of possible error types.
///
/// - ParseError: an error during parsing the items of a certain type, if they are received; type: type of the data this error happened to, human-readable string.
/// - LoadError: an error triggered if nothing came at all.
public enum RedditError: Error {
    case ParseError(type: String)
    case LoadError(type: String)
    
    /// Gets the human-readable description for one of errors.
    ///
    /// - Parameter error: type of error.
    /// - Returns: description for that error.
    static func getDescriptionForError(_ error: RedditError) -> String {
        switch(error) {
        case .ParseError(let type):
            return "Could not parse \(type)"
        case .LoadError(let type):
            return "Could not get \(type) from server"
        }
    }
}
