//
//  CommentUtils.swift
//  testreddit
//
//  Created by Alexander on 6/23/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// Utils for working with comment trees.
class CommentUtils {
    
    
    /// Marks comment opened or closed based on the index of the clicked comment.
    ///
    /// - Parameters:
    ///   - currentIndex: current index we have reached so far
    ///   - lastIndex: index of the comment we need to mark
    ///   - commentsSubTree: comment list we are working with
    /// - Returns: index we stopped at
    class func markComments(currentIndex: Int, commentToMark lastIndex: Int, comments commentsSubTree: [Comment]) -> Int {
        var current = currentIndex
        for comment in commentsSubTree {
            if current > lastIndex {
                break;
            }
            current += 1
            if (current == lastIndex) {
                comment.opened = !comment.opened
                break
            } else
                if comment.opened,
                    let replies = comment.replies {
                    current = markComments(currentIndex: current, commentToMark: lastIndex, comments: replies)
            }
        }
        return current
    }
    
    
    /// Finds a comment at a certain index and checks its level.
    ///
    /// - Parameters:
    ///   - currentIndex: current index we have reached so far
    ///   - lastIndex: index of the comment we are looking for.
    ///   - level: current level of the comment tree
    ///   - commentsSubTree: comment sub tree we have reached
    /// - Returns: level we have reached, index we have reached, and the comment, if it is found (otherwise nil)
    class func findComment(currentIndex: Int, indexOfTheComment lastIndex: Int, level: Int, comments commentsSubTree: [Comment]) -> (Int, Int, Comment?) {
        var current = currentIndex
        let currentLevel = level + 1
        for comment in commentsSubTree {
            current += 1
            if current > lastIndex {
                break;
            }
            if (current == lastIndex) {
                return (currentLevel, current, comment)
            } else
                if comment.opened,
                    let replies = comment.replies {
                    let (returnedLevel, returnedIndex, returnedComment) = findComment(currentIndex: current, indexOfTheComment: lastIndex, level: currentLevel, comments: replies)
                    if let foundComment = returnedComment {
                        return (returnedLevel, current, foundComment)
                    } else {
                        current = returnedIndex
                    }
            }
        }
        return (currentLevel, current, nil)
    }
    
    
    /// Counts the number of comments we need to show.
    ///
    /// - Parameters:
    ///   - initialCount: current number of comments we have calculated
    ///   - commentsSubTree: comment sub tree we have reached
    /// - Returns: number of the comments shown
    class func countComments(initialCount: Int, comments commentsSubTree: [Comment]) -> Int {
        var initial = initialCount
        for comment in commentsSubTree {
            initial += 1
            if comment.opened,
                let replies = comment.replies {
                initial = countComments(initialCount: initial, comments: replies)
            }
        }
        return initial
    }
    
}
