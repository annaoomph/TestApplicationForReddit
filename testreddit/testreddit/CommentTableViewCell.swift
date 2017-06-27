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

}
