//
//  ViewController.swift
//  testreddit
//
//  Created by Alexander on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CommentsDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var post: LinkM?
    var comments: [Comment] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        startRefreshControl()
        refresh(sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func indices(curInd: Int, lastInd: Int, _ comments: [Comment]) -> Int {
        var currentIndex = curInd
        for comment in comments {
            if currentIndex > lastInd {
                break;
            }
            currentIndex += 1
            if (currentIndex == lastInd) {
                comment.opened = !comment.opened
                break
            } else
                if comment.opened,
                    let replies = comment.replies {
                    currentIndex = indices(curInd: currentIndex, lastInd: lastInd, replies)
            }
        }
        return currentIndex
    }
    
    func findComment(curInd: Int, lastInd: Int, level: Int, _ comments: [Comment]) -> (Int, Int, Comment?) {
        var currentIndex = curInd
        let currentLevel = level + 1
        for comment in comments {
            currentIndex += 1
            if currentIndex > lastInd {
                break;
            }
            if (currentIndex == lastInd) {
                return (currentLevel, currentIndex, comment)
            } else
                if comment.opened,
                    let replies = comment.replies {
                    let (cLevel, index, commentF) = findComment(curInd: currentIndex, lastInd: lastInd, level: currentLevel, replies)
                    if let foundComment = commentF {
                        return (cLevel, currentIndex, foundComment)
                    } else {
                        currentIndex = index
                    }
            }
        }
        return (currentLevel, currentIndex, nil)
    }
    
    func countComments(initialCount: Int, _ comments: [Comment]) -> Int {
        var inC = initialCount
        for comment in comments {
            inC += 1
            if comment.opened,
                let replies = comment.replies {
                inC = countComments(initialCount: inC, replies)
            }
        }
        return inC
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indices(curInd: -1, lastInd: indexPath.row, comments)
        
        tableView.reloadData()
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         return tableView.cellForRow(at: indexPath)!.contentView.frame.size.height + 8

    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellsCount = countComments(initialCount: 0, comments)
        return cellsCount
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else {
            fatalError("Not loaded cell")
        }
        let (level, _, commentF) = findComment(curInd: -1, lastInd: indexPath.row, level: -1, comments)
        if let comment = commentF {
            
            cell.titleLabel.text = comment.body
        }
        let margin = String(repeating: "    ", count: level)
        cell.marginLabel.text = "\(margin)>"
        return cell
    }
    
    //MARK: - Refreshing
    func startRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(PostsTableViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.refreshControl!.beginRefreshing()
    }
    
    func refresh(sender:AnyObject) {
        if let realPost = post {
            titleLabel.text = realPost.title
            CommentsSession().getComments(postId: realPost.id, callback: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Comments Delegate
    func onError(error: String) {
        DispatchQueue.main.sync() {
            tableView.reloadData()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    func onCommentsDelivered(comments: [Comment]) {
        self.comments = comments
        DispatchQueue.main.sync() {
            tableView.reloadData()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
}

