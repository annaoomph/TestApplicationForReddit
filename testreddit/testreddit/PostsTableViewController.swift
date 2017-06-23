//
//  PostsTableViewController.swift
//  testreddit
//
//  Created by Alexander on 6/16/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class PostsTableViewController: UITableViewController {
    
    //MARK: - Properties
    //Contains the list of posts from the internet.
    var postsList = [LinkM]()
    
    //Defines whether the table should show local or loaded from the internet version of data.
    var local = false
    
    let loader = Loader()
    
    /// Stores the id of the last loaded from the server post.
    var lastPost: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startRefreshControl()
        CoreDataManager.instance.getAll()
        refresh(sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset;
        let bounds = scrollView.bounds;
        let size = scrollView.contentSize;
        let inset = scrollView.contentInset;
        let y = offset.y + bounds.size.height - inset.bottom;
        let h = size.height;
        let reload_distance = CGFloat(50);
        if y > h + reload_distance {
            loader.getPosts(more: true, lastPost: lastPost, callback: onMorePostsDelivered(posts: after: error:))
        }
        
    }
    
    //MARK: - Refreshing
    func startRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(PostsTableViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
        refreshControl!.beginRefreshing()
    }
    
    func refresh(sender:AnyObject) {
        loader.getPosts(callback: onPostsDelivered(posts: after: error:))
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (local) ? CoreDataManager.instance.getPostCount() : postsList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCellTableViewCell else {
            fatalError("Not loaded cell")
        }
        var post: LinkM
        if (local) {
            post = CoreDataManager.instance.getPostAt(indexPath: indexPath)
        } else {
            post = postsList[indexPath.row]
        }
        
        cell.titleLabel.text = post.title
        cell.scoreLabel.text = "\(post.score)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if local {
            return "Can't connect to server. Showing cashed posts"
        } else {
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.backgroundView?.backgroundColor = UIColor.red
    }
    
    //MARK: - Callbacks
    
    func onPostsDelivered(posts: [LinkM]?, after: String?, error: String?) {
        lastPost = after
        if let errorString = error {
            local = true
        } else {
            local = false
        }
        if let receivedPosts = posts {
            postsList = receivedPosts
        }
        DispatchQueue.main.sync() {
            tableView.reloadData()
            refreshControl!.endRefreshing()
        }
    }
    
    func onMorePostsDelivered(posts: [LinkM]?, after: String?, error: String?) {
        lastPost = after
        if let errorString = error {
            local = true
        }else {
            local = false
        }
        if let receivedPosts = posts {
            postsList += receivedPosts
        }
        DispatchQueue.main.sync() {
            tableView.reloadData()
            if error == nil {
                let indexPath = IndexPath(row: postsList.count - 25, section: 0)
                tableView.scrollToRow(at: indexPath,
                                      at: UITableViewScrollPosition.middle, animated: true)
            }
        }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "ShowItem":
            guard let postController = segue.destination as? ViewController else {
                fallthrough
            }
            guard let selectedTableCell = sender as? UITableViewCell else {
                fallthrough
            }
            guard let selectedIndex = tableView.indexPath(for: selectedTableCell) else {
                fallthrough
            }
            let post = postsList[selectedIndex.row]
            postController.post = post
        default:
            fatalError("Unexpected destination")
        }
    }   
    
}
