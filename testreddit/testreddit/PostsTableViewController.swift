//
//  PostsTableViewController.swift
//  testreddit
//
//  Created by Anna on 6/16/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit
import CoreData

/// This protocol must be implemented by the detail view controller, if we have split view.
protocol PostSelectionDelegate: class {
    
    /// Called when the post is selected.
    ///
    /// - Parameter newPost: selected post.
    func postSelected(newPost: LinkM)
}

/// A controller displaying a list of posts.
class PostsTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UITabBarControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate {
    
    //MARK: - Properties
    
    /// A table for the posts.
    @IBOutlet weak var tableView: UITableView!
    
    /// Loader for loading data from server.
    let loader = Loader()
    
    /// Whether the request to server is still loading.
    var refreshingInProgress = false
    
    /// Controller for loading data from local database.
    var fetchedResultsControllerForPosts: NSFetchedResultsController<LinkM>?
    
    /// Delegate from detail view controller listening to selected post events (when using split view, otherwise this is nil).
    weak var postSelectionDelegate: PostSelectionDelegate?
    
    /// Defines whether the tab bar controller delegate is attached.
    var tabControllerDelegateAttached = false
    
    /// Loaded from database posts filtered by user.
    var filteredPosts = [LinkM]()
    
    /// Search controller for the table view.
    let searchController = UISearchController(searchResultsController: nil)
    
    /// Whether the authorization was already asked in this session.
    static var askedAuthorization = false
    
    /// Retrieves the chosen search scope name (raw value of enum).
    var scope: String {
        get {
            return searchController.searchBar.scopeButtonTitles![searchController.searchBar.selectedScopeButtonIndex]
        }
    }
    
    /// Checks whether the device is ipad
    var isIpad: Bool {
        get{
            return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad
        }
    }
    
    /// Defines whether the search is in progress.
    var searching: Bool {
        get {
            //The search is active either when user types in some text or when he chooses some scope (even without typing).
            return searchController.isActive && (searchController.searchBar.text != "" || scope != "All")
        }
    }
    
    /// Retrieves the search text.
    var searchText: String {
        get {
            return searchController.searchBar.text!.lowercased()
        }
    }
    
    /// Get the post type currently shown in a tab.
    var selectedPostType: ContentType.PostType {
        get {
            return ContentType.PostType.getPostType(selectedTab: (tabBarController?.selectedIndex)!)
        }
    }
    
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
            tabBarController!.delegate = self
            tabControllerDelegateAttached = true
        }
        if tabBarController!.selectedIndex == 0 {
            title = ContentType.PostType.HOT.rawValue
        } else {
            title = ContentType.PostType.NEW.rawValue
        }
        tableView.dataSource = self
        tableView.delegate = self
        initializeSearch()
        startRefreshControl()
        loadFromDatabase()
        checkForUserAuthorization()
    }
    
    /// Checks whether the user is authorized and if not, tries to ask him to do so, if it's possible.
    func checkForUserAuthorization() {
        //If user is not authorized, allowed to be asked and the alert has not yet been shown - show alert. Otherwise do nothing.
        if !PreferenceManager().isUserAuth() && !PreferenceManager().isUserPermittedToBeAsked() && !PostsTableViewController.askedAuthorization {
            PostsTableViewController.askedAuthorization = true
            
            let alertController = UIAlertController(title: "Authorization", message: Configuration.USER_AUTH_QUESTION, preferredStyle:
                (isIpad) ? .alert : .actionSheet)
            let OKAction = UIAlertAction(title: Configuration.USER_AUTH_OPTIONS[0], style: .default, handler: {
                _ in Loader.authorizeUser()
            })
            let DiscardAction = UIAlertAction(title: Configuration.USER_AUTH_OPTIONS[1], style: .destructive, handler: {
                _ in PreferenceManager().userDoesntWantAuthorized()
            })
            let LaterAction = UIAlertAction(title: Configuration.USER_AUTH_OPTIONS[2], style: .cancel)
            alertController.addAction(OKAction)
            alertController.addAction(DiscardAction)
            alertController.addAction(LaterAction)
            
            self.present(alertController, animated: true, completion: {})
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        PreferenceManager().saveOpenedTab(tab: tabBarController.selectedIndex)
        refresh(sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    /// Event when user drags table view from the bottom to load more posts.
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
                loader.getPostsOfType(selectedPostType, more: true, callback: onMorePostsDelivered(posts: error:))
            }
        }
    }
    
    //MARK: - Refreshing
    func startRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(PostsTableViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
    }
    
    func refresh(sender:AnyObject) {
        if !refreshingInProgress {
            tableView.refreshControl?.beginRefreshing()
            refreshingInProgress = true
            loader.getPostsOfType(selectedPostType, callback: onPostsDelivered(posts: error:))
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
    
    /// Gets the number of posts in the database (or filtered).
    ///
    /// - Returns: amount of posts.
    func getPostCount() -> Int {
        if searching {
            return filteredPosts.count
        }
        return fetchedResultsControllerForPosts?.fetchedObjects?.count ?? 0
    }
    
    /// Gets post at certain index path.
    ///
    /// - Parameter indexPath: index of the post.
    /// - Returns: post.
    func getPostAt(indexPath: IndexPath) -> LinkM {
        if searching {
            return filteredPosts[indexPath.row]
        }
        return fetchedResultsControllerForPosts!.object(at: indexPath)
    }
    
    /// Gets an array of posts from the database.
    ///
    /// - Returns: array of posts (can be empty if something goes wrong)
    func getPosts() -> [LinkM] {
        return fetchedResultsControllerForPosts?.fetchedObjects ?? [LinkM]()
    }
    
    //MARK: - Filtering
    
    /// Initializes search components.
    func initializeSearch() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.scopeButtonTitles = [ScopeType.All.rawValue, ScopeType.Image.rawValue, ScopeType.Gif.rawValue, ScopeType.Other.rawValue]
        searchController.searchBar.delegate = self
    }
    
    /// Filters the array of posts by the search string and entered scope.
    ///
    /// - Parameters:
    ///   - searchText: a text user typed in to search
    ///   - scope: a scope user has chosen
    func filterContentForSearchString(searchText: String, scope: String = "All") {
        filteredPosts = getPosts().filter {
            var scopeMatches = false
            switch (scope) {
            case ScopeType.Image.rawValue:
                if ($0.image != nil) {
                    scopeMatches = true
                }
            case ScopeType.Gif.rawValue:
                if ($0.additionalData != nil) {
                    scopeMatches = true
                }
            case ScopeType.Other.rawValue:
                if ($0.additionalData == nil && $0.image == nil) {
                    scopeMatches = true
                }
            default:
                scopeMatches = true
            }
            //If the search string contains something, we check if the title contains it, otherwise we skip this check.
            return scopeMatches && (searchText.characters.count > 0 ? $0.title.lowercased().contains(searchText.lowercased()) : true)
        }
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchString(searchText: searchText, scope: scope)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchString(searchText: searchText, scope: searchBar.scopeButtonTitles![selectedScope])
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
        if searching {
            cell.constructLabels(with: post, searchString: searchText)
        } else {
            cell.constructLabels(with: post)
        }
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
    
    /// Called when fetch controller has loaded its items.
    ///
    /// - Parameter controller: fetch controller
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if getPostCount() > 0 {
            tableView.reloadData()
        }
    }
    
    /// Called when server has loaded posts.
    ///
    /// - Parameters:
    ///   - posts: posts from server.
    ///   - error: error, if it happened.
    func onPostsDelivered(posts: [LinkM]?, error: Error?) {
        refreshingInProgress = false
        if let caughtError = error {
            displayError(caughtError)
        }
        DispatchQueue.main.sync() {
            tableView.refreshControl?.endRefreshing()
            if postSelectionDelegate != nil {
                tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: UITableViewScrollPosition.top)
                postSelectionDelegate?.postSelected(newPost: getPostAt(indexPath: IndexPath(item: 0, section: 0)))
            }
        }
    }
    
    /// Called when server has loaded more posts.
    ///
    /// - Parameters:
    ///   - posts: a list of posts to be added.
    ///   - error: error, if it happened.
    func onMorePostsDelivered(posts: [LinkM]?, error: Error?) {
        refreshingInProgress = false
        if let caughtError = error {
            displayError(caughtError)
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
    
    /// Displays a certain error.
    ///
    /// - Parameter error: error object
    func displayError(_ error: Error) {
        let errorString = error is RedditError ? RedditError.getDescriptionForError(error as! RedditError) : error.localizedDescription
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
