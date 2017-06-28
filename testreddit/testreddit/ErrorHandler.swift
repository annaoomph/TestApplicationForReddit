//
//  ErrorHandler.swift
//  testreddit
//
//  Created by Alexander on 6/28/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
public enum RedditError: Error {
    case ParseError(type: String)
    case LoadError(type: String)
}

public class ErrorHandler {
    static func getDescriptionForError(error: RedditError) -> String {
        switch(error) {
        case .ParseError(let type): return "Could not parse \(type)"
        case .LoadError(let type): return "Could not get \(type) from server"
        }
    }

}
