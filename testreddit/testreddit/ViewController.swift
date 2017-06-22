//
//  ViewController.swift
//  testreddit
//
//  Created by Alexander on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CommentsDelegate, UITableViewDataSource {

    var post: LinkM?
    var comments: [Comment] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh(sender: self)
        tableView.dataSource = self
        startRefreshControl()
    }

    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else {
            fatalError("Not loaded cell")
        }
        let comment = comments[indexPath.row]
        
        cell.titleLabel.text = comment.body
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

