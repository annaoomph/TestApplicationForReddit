//
//  ViewController.swift
//  testreddit
//
//  Created by Alexander on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CommentsDelegate {

    var post: LinkM?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let realPost = post {
            titleLabel.text = realPost.title
            CommentsSession().getComments(postId: realPost.id, callback: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func onError(error: String) {
        
    }
    
    func onCommentsDelivered(comments: [Comment]) {
        
    }

}

