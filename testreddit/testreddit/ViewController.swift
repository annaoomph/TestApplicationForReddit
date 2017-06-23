//
//  ViewController.swift
//  testreddit
//
//  Created by Alexander on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit


/// A controller for the post view.
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    /// Shown post (link).
    var post: LinkM?
    
    /// A list of comments for the shown post.
    var comments: [Comment] = []
    
    let loader = Loader()
    
    @IBOutlet weak var tableView: UITableView!    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
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
    
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CommentUtils.markComments(currentIndex: -1, commentToMark: indexPath.row, comments: comments)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellsCount = CommentUtils.countComments(initialCount: 0, comments: comments)
        return cellsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else {
            fatalError("Not loaded cell")
        }
        let (level, _, returnedComment) = CommentUtils.findComment(currentIndex: -1, indexOfTheComment: indexPath.row, level: -1, comments: comments)
        var mark = "  "
        if let comment = returnedComment {
            cell.titleLabel.text = comment.body
            if let replies = comment.replies,
                replies.count > 0 {
                mark = ">"
            }
        }
        let margin = String(repeating: "    ", count: level)
        cell.marginLabel.text = "\(margin)\(mark)"
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
            loader.getComments(postId: realPost.id, callback: onCommentsDelivered(comments:error:))
        }
    }
    
    //MARK: - Callbacks
    func onCommentsDelivered(comments: [Comment]?, error: String?) {
        if let receivedComments = comments {
            self.comments = receivedComments
        } else if let errorString = error {
        //TODO: Show UIAlert
        }
        DispatchQueue.main.sync() {
            tableView.reloadData()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
}

