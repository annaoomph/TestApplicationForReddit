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
    var currentIndex: Int
    
    init() {
        currentIndex = -1
    }
    
    /// Marks comment opened or closed based on the index of the clicked comment.
    ///
    /// - Parameters:
    ///   - currentIndex: current index we have reached so far
    ///   - lastIndex: index of the comment we need to mark
    ///   - commentsSubTree: comment list we are working with
    func markComments(commentToMark lastIndex: Int, comments commentsSubTree: [Comment]) {
        for comment in commentsSubTree {
            if currentIndex > lastIndex {
                break;
            }
            currentIndex += 1
            if (currentIndex == lastIndex) {
                comment.opened = !comment.opened
                break
            } else
                if comment.opened,
                    let replies = comment.replies {
                    markComments(commentToMark: lastIndex, comments: replies)
            }
        }
    }
    
    
    /// Finds a comment at a certain index and checks its level.
    ///
    /// - Parameters:
    ///   - lastIndex: index of the comment we are looking for.
    ///   - level: current level of the comment tree
    ///   - commentsSubTree: comment sub tree we have reached
    /// - Returns: level we have reached, and the comment, if it is found (otherwise nil)
    func findCommentByIndex(_ lastIndex: Int, level: Int, comments commentsSubTree: [Comment]) -> (Int, Comment?) {
        let currentLevel = level + 1
        for comment in commentsSubTree {
            currentIndex += 1
            if currentIndex > lastIndex {
                break;
            }
            if (currentIndex == lastIndex) {
                return (currentLevel, comment)
            } else
                if comment.opened,
                    let replies = comment.replies {
                    let (returnedLevel, returnedComment) = findCommentByIndex(lastIndex, level: currentLevel, comments: replies)
                    if let foundComment = returnedComment {
                        return (returnedLevel, foundComment)
                    }
            }
        }
        return (currentLevel, nil)
    }
    
    
    /// Counts the number of comments we need to show.
    ///
    /// - Parameters:
    ///   - initialCount: current number of comments we have calculated
    ///   - commentsSubTree: comment sub tree we have reached
    /// - Returns: number of the comments shown
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
