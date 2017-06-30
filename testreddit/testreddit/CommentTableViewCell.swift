//
//  CommentTableViewCell.swift
//  testreddit
//
//  Created by Alexander on 6/22/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    
    /// A label for margin defining the tree label, also displays the pointer (>/v).
    @IBOutlet weak var marginLabel: UILabel!
    
    /// A label with comment body.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// A label with additional information about the comment.
    @IBOutlet weak var infoLabel: UILabel!
    
    /// Constructs the text on all of the cell labels.
    ///
    /// - Parameters:
    ///   - comment: the comment itself
    ///   - level: level of the comment in a comment tree
    func constructLabels(comment: Comment, level: Int) {
        var mark = "  "
        var repliesText = "0"
        if let replies = comment.replies,
            replies.count > 0 {
            mark = comment.opened ? "v" : ">"
            repliesText = "\(replies.count)"
        }
        let mutableString = NSMutableAttributedString(string: "\(comment.score) \(comment.author) replies: \(repliesText)", attributes: nil)
        mutableString.addAttribute(NSForegroundColorAttributeName, value: Configuration.Colors.red, range: NSRange(location: 0, length:"\(comment.score)".characters.count))
        mutableString.addAttribute(NSForegroundColorAttributeName, value: Configuration.Colors.blue, range: NSRange(location: "\(comment.score)".characters.count + 1, length:comment.author.characters.count))
        infoLabel.attributedText = mutableString        
        let margin = String(repeating: "    ", count: level)
        marginLabel.text = "\(margin)\(mark)"
        titleLabel.text = comment.body
    }
}
