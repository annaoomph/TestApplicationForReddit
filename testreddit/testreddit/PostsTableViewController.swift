//
//  PostsTableViewController.swift
//  testreddit
//
//  Created by Alexander on 6/16/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit
import CoreData

protocol PostSelectionDelegate: class {
    func postSelected(newPost: LinkM)
}
class PostsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITabBarControllerDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    
    /// Loader for loading data from server.
    let loader = Loader()
    
    /// Whether the request to server is still loading.
    var refreshingInProgress = false
    
    /// Controller for loading data from local database.
    var fetchedResultsControllerForPosts: NSFetchedResultsController<LinkM>?
    
    /// Delegate from detail view controller listening to selected post events.
    weak var postSelectionDelegate: PostSelectionDelegate?
    
    /// Defines whether the tab bar controller delegate is attached.
    var tabControllerDelegateAttached = false
    
    //MARK: - Lifecycle events
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If the device is iPad, the variable with split controller would be defined, and we need to attach a delegate to this controller.
        if let split = splitViewController {
            if let navController = split.viewControllers.last as? UINavigationController {
                let detailViewController = navController.topViewController as! PostDetailViewController
                self.postSelectionDelegate = detailViewController
            }
        }
        
        //Attach the tab bar delegate to listen when user switches between tabs.
        //We don't need this behaviour the first time a tab appears, so the initial setup's done here.
        if !tabControllerDelegateAttached {
            tabBarController?.delegate = self
            tabControllerDelegateAttached = true
        }
        if tabBarController?.selectedIndex == 0 {
            title = ContentType.PostType.HOT.rawValue
        } else {
            title = ContentType.PostType.NEW.rawValue
        }
        tableView.dataSource = self
        tableView.delegate = self
        startRefreshControl()
        loadFromDatabase()
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        PreferenceManager().saveOpenedTab(tab: tabBarController.selectedIndex)
        refresh(sender: self)
        
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
            if !refreshingInProgress {
                refreshingInProgress = true
                tableView.refreshControl?.beginRefreshing()
                loader.getPosts(type: ContentType.PostType.getPostType(selectedTab: (tabBarController?.selectedIndex)!), more: true, callback: onMorePostsDelivered(posts: error:))
            }
        }
    }
    
    //MARK: - Refreshing
    func startRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.addTarget(self, action: #selector(PostsTableViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
    }
    
    func refresh(sender:AnyObject) {
        if !refreshingInProgress {
            tableView.refreshControl?.beginRefreshing()
            refreshingInProgress = true
            loader.getPosts(type: ContentType.PostType.getPostType(selectedTab: (tabBarController?.selectedIndex)!), callback: onPostsDelivered(posts: error:))
        }
    }
    
    //MARK: - Fetching
    func loadFromDatabase() {
        let fetchRequest = NSFetchRequest<LinkM>(entityName: "LinkM")
        let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsControllerForPosts = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsControllerForPosts!.delegate = self
        //Execute fetch request for table data source.
        do {
            //If the execution fails here, we take items from server right away and don't check the number of items.
            try fetchedResultsControllerForPosts!.performFetch()
            //Check if there are items in a database and send request to server if there are none.
            DispatchQueue.global().async {
                let objects = try! CoreDataManager.instance.managedObjectContext.fetch(fetchRequest)
                if objects.count == 0 {
                    self.refresh(sender: self)
                }
            }
        } catch {
            self.refresh(sender: self)
        }
        
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
        return fetchedResultsControllerForPosts!.object(at: indexPath)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getPostCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            fatalError("Not loaded cell")
        }
        let post = getPostAt(indexPath: indexPath)
        
        cell.constructLabels(post: post)
        if post.thumbnailEnabled(),
            let checkedUrl = URL(string: post.thumbnail) {
            cell.downloadImage(url: checkedUrl)
        } else {
            cell.imgView.image = #imageLiteral(resourceName: "Placeholder")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //If the delegate is not nil, it executes its method notifying that another cell is chosen.
        self.postSelectionDelegate?.postSelected(newPost: getPostAt(indexPath: indexPath))
    }
    
    //MARK: - Callbacks
    func onPostsDelivered(posts: [LinkM]?, error: Error?) {
        refreshingInProgress = false
        if let caughtError = error {
            displayError(error: caughtError)
        }
        DispatchQueue.main.sync() {
            tableView.refreshControl!.endRefreshing()
            if postSelectionDelegate != nil {
                tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
                postSelectionDelegate?.postSelected(newPost: getPostAt(indexPath: IndexPath(item: 0, section: 0)))
            }
        }
    }
    
    func onMorePostsDelivered(posts: [LinkM]?, error: Error?) {
        refreshingInProgress = false
        if let caughtError = error {
            displayError(error: caughtError)
        }
        DispatchQueue.main.sync() {
            if error == nil {
                //Scrolls to the middle of the loaded posts so the user can see that they are loaded.
                let indexPath = IndexPath(row: getPostCount() - 25, section: 0)
                tableView.scrollToRow(at: indexPath,
                                      at: UITableViewScrollPosition.middle, animated: true)
                if postSelectionDelegate != nil {
                    tableView.selectRow(at: IndexPath(item: getPostCount() - 25, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
                    //Select the top post, if there is a delegate.
                    postSelectionDelegate?.postSelected(newPost: getPostAt(indexPath: IndexPath(item: getPostCount() - 25, section: 0)))
                }
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
    
    /// Called when fetch controller has loaded its items.
    ///
    /// - Parameter controller: fetch controller
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if getPostCount() > 0 {
            tableView.reloadData()
        }
    }
    
    /// Displays a certain error.
    ///
    /// - Parameter error: error object
    func displayError(error: Error) {
        let errorString = error is RedditError ? ErrorHandler.getDescriptionForError(error: error as! RedditError) : error.localizedDescription
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
