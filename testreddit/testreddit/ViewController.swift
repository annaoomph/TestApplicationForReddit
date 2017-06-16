//
//  ViewController.swift
//  testreddit
//
//  Created by Alexander on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var post: Link?
    
    
    @IBOutlet weak var titleLabel: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        if let realPost = post {
            titleLabel.text = realPost.title
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

