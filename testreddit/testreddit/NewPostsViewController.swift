//
//  PostsTableViewController.swift
//  testreddit
//
//  Created by Alexander on 6/16/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit
import CoreData

class NewPostsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    //MARK: - Properties
    //Contains the list of posts from the internet.
    var postsList = [LinkM]()
    
     
    @IBOutlet weak var tableView: UITableView!
    
    //Defines whether the table should show local or loaded from the internet version of data.
    var local = false
    
    /// Loader for loading data from server.
    let loader = Loader()
    
    /// Stores the id of the last loaded from the server post.
    var lastPost: String?
    
    /// Controller for loading data from local database.
    var fetchedResultsControllerForPosts: NSFetchedResultsController<LinkM>?
    
    //MARK: - Lifecycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
      //  startRefreshControl()
       // loadFromDatabase()
       // refresh(sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset = scrollView.contentOffset;
        let bounds = scrollView.bounds;
        let size = scrollView.contentSize;
        let inset = scrollView.contentInset;
        let y = offset.y + bounds.size.height - inset.bottom;
        let height = size.height;
        let reloadDistance = CGFloat(50);
        if y > height + reloadDistance {
            //loader.getPosts(more: true, lastPost: lastPost, callback: onMorePostsDelivered(posts: after: error:))
        }
    }
    
    //MARK: - Refreshing
    func startRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(PostsTableViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.refreshControl!.beginRefreshing()
    }
    
    func refresh(sender:AnyObject) {
       // loader.getPosts(callback: onPostsDelivered(posts: after: error:))
    }
    
    //MARK: - Fetching
    func loadFromDatabase() {
        let fetchRequest = NSFetchRequest<LinkM>(entityName: "LinkM")
        let sortDescriptor = NSSortDescriptor(key: "score", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsControllerForPosts = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        try! fetchedResultsControllerForPosts!.performFetch()
    }
    
    
    /// Gets the number of posts in the database.
    ///
    /// - Returns: amount of posts
    func getPostCount() -> Int {
        return fetchedResultsControllerForPosts!.fetchedObjects?.count ?? 0
    }
    
    /// Gets post at certain index path.
    ///
    /// - Parameter indexPath: index of the post
    /// - Returns: post
    func getPostAt(indexPath: IndexPath) -> LinkM {
        return local ? fetchedResultsControllerForPosts!.object(at: indexPath) : postsList[indexPath.row]
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (local) ? getPostCount() : postsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            fatalError("Not loaded cell")
        }
        let post = getPostAt(indexPath: indexPath)
        
        cell.titleLabel.text = post.title
        cell.scoreLabel.text = "\(post.score)"
        cell.scoreLabel.textColor = Configuration.Colors.red
        let date = DateFormatter.localizedString(from: Date(timeIntervalSince1970: TimeInterval(post.created)), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
        //Building colored info string.
        if let author = post.author {
            let domain = post.is_self ? "" : "at \(post.domain)"
            let mutableString = NSMutableAttributedString(string: "Submitted at \(date) by \(author) to \(post.subreddit) \(domain)", attributes: nil)
            mutableString.addAttribute(NSForegroundColorAttributeName, value: Configuration.Colors.green, range: NSRange(location: 13, length:String(date)!.characters.count))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: Configuration.Colors.blue, range: NSRange(location: 17 + String(date)!.characters.count, length: author.characters.count))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: Configuration.Colors.orange, range: NSRange(location: mutableString.length - post.subreddit.characters.count - domain.characters.count - 1, length: post.subreddit.characters.count))
            if domain.characters.count > 0 {
                mutableString.addAttribute(NSForegroundColorAttributeName, value: Configuration.Colors.red, range: NSRange(location: mutableString.length - domain.characters.count + 3, length: domain.characters.count - 3))
            }
            cell.infoLabel.attributedText = mutableString
        }
        if let checkedUrl = URL(string: post.thumbnail) {
            cell.downloadImage(url: checkedUrl)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return local ? "Can't connect to server. Showing cashed posts" : ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
        header.backgroundView?.backgroundColor = UIColor.red
    }
    
    //MARK: - Callbacks
    func onPostsDelivered(posts: [LinkM]?, after: String?, error: Error?) {
        lastPost = after
        if let caughtError = error {
            local = true
            displayError(error: caughtError)
        } else {
            local = false
        }
        if let receivedPosts = posts {
            postsList = receivedPosts
        }
        DispatchQueue.main.sync() {
            tableView.reloadData()
            tableView.refreshControl!.endRefreshing()
        }
    }
    
    func onMorePostsDelivered(posts: [LinkM]?, after: String?, error: Error?) {
        lastPost = after
        if let caughtError = error {
            local = true
            displayError(error: caughtError)
        } else {
            local = false
        }
        if let receivedPosts = posts {
            postsList += receivedPosts
        }
        DispatchQueue.main.sync() {
            tableView.reloadData()
            if error == nil {
                //Scrolls to the middle of the loaded posts so the user can see that they are loaded.
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
            guard let postController = segue.destination as? PostDetailViewController else {
                fallthrough
            }
            guard let selectedTableCell = sender as? UITableViewCell else {
                fallthrough
            }
            guard let selectedIndex = tableView.indexPath(for: selectedTableCell) else {
                fallthrough
            }
            postController.post = getPostAt(indexPath: selectedIndex)
        default:
            fatalError("Unexpected destination")
        }
    }
    
    
    /// Displays a certain error.
    ///
    /// - Parameter errorString: a string describing the error
    func displayError(error: Error) {
        let errorString = error is RedditError ? ErrorHandler.getDescriptionForError(error: error as! RedditError) : error.localizedDescription
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
