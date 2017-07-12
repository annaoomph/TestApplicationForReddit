//
//  CommentUtils.swift
//  testreddit
//
//  Created by Anna on 6/23/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

/// Utils for working with comment trees. Warning: this class should be initialized every time a function is used.
class CommentUtils {
    
    /// Current index (used for recursion).
    var currentIndex: Int
    
    init() {
        currentIndex = -1
    }
    
    
    /// Finds a comment at a certain index and calculates its level.
    ///
    /// - Parameters:
    ///   - lastIndex: index of the comment we are looking for.
    ///   - level: the level of the comment tree reached so far.
    ///   - commentsSubTree: comment sub tree reached so far.
    /// - Returns: level of the comment, and the comment, if it is found (otherwise nil).
    func findCommentByIndex(_ lastIndex: Int, level: Int, comments commentsSubTree: [Comment]) -> (comment: Comment?, at: Int) {
        let currentLevel = level + 1
        for comment in commentsSubTree {
            currentIndex += 1
            if currentIndex > lastIndex {
                break;
            }
            if (currentIndex == lastIndex) {
                return (comment: comment, at: currentLevel)
            } else {
                if let found = comment[lastIndex - currentIndex - 1] {
                    return (comment: found, at: currentLevel + 1)
                } else {
                    if comment.opened,
                        let replies = comment.replies {
                        let (returnedComment, returnedLevel) = findCommentByIndex(lastIndex, level: currentLevel, comments: replies)
                        if let foundComment = returnedComment {
                            return (comment: foundComment, at: returnedLevel)
                        }
                    }
                }
            }
        }
        return (comment: nil, at: currentLevel)
    }
    
    
    /// Counts the number of comments we need to show.
    ///
    /// - Parameters:
    ///   - initialCount: current number of comments we have calculated.
    ///   - commentsSubTree: comment subtree reached so far.
    /// - Returns: number of the comments to show.
    func countComments(initialCount: Int, comments commentsSubTree: [Comment]) -> Int {
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
