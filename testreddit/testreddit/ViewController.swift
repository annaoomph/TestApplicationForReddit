//
//  ViewController.swift
//  testreddit
//
//  Created by Alexander on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CommentsDelegate {

    var post: Link?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleLabel: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let realPost = post {
            titleLabel.text = realPost.title
            CommentsSession().getComments(postId: realPost.id, callback: self)
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func onError(error: String) {
        
    }
    
    func onCommentsDelivered(comments: [Comment]) {
        
    }

}

