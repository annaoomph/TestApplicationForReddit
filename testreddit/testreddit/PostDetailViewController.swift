//
//  ViewController.swift
//  testreddit
//
//  Created by Anna on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit
import SwiftGifOrigin

/// A controller for the post detailed view.
class PostDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostSelectionDelegate {
    
    //MARK: - Storyboard elements
    /// A view with the image or gif attached to the post. Can contain empty placeholder, if no image or gif is provided.
    @IBOutlet weak var imgView: UIImageView!
    
    /// An activity indicator that isshown when an image or gif is still loading.
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    
    /// A toggle button for showing/hiding a list of comments.
    @IBOutlet weak var showHideComments: UIButton!
    
    /// A table for comments.
    @IBOutlet weak var tableView: UITableView!
    
    /// Label showing contents of the post (selftext).
    @IBOutlet weak var textLabel: UILabel!
    
    /// View's internal scroll view (as the content can be pretty big because of text and images).
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// Displays the title of the post.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Label notifying that the post looks better in a browser.
    @IBOutlet weak var hintLabel: UILabel!
    
    //MARK: - Properties
    /// Loads data from server.
    let loader = Loader()
    
    /// An image or gif connected with the post.
    var mainImage: UIImage?
    
    /// Shown post (link).
    var post: LinkM?
    
    /// A popup for displaying full-sized image.
    var popupWindow: PopupViewController?
    
    /// A popup for displaying post in a web view.
    var popupWebWindow: PopupWebViewController?
    
    /// A list of comments for the shown post.
    var comments: [Comment] = []
    
    /// Whether the request to server is still loading.
    var refreshingInProgress = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        startRefreshControl()
        loadPost()
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
        //When a comment row is selected, it is needed to open or close the comment, if it's possible.
        //Basically, here we only need to modify a boolean flag on the comment, indicating its state.
        let result = CommentUtils().findCommentByIndex(indexPath.row, level: -1, comments: comments)
        if let comment = result.comment {
            comment.opened  = !comment.opened
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentUtils().countComments(initialCount: 0, comments: comments)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else {
            fatalError("Not loaded cell")
        }
        let result = CommentUtils().findCommentByIndex(indexPath.row, level: -1, comments: comments)
        
        if let comment = result.comment {
            cell.constructLabels(with: comment, level: result.at)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let selectedPost = post {
            return "Comments: \(selectedPost.num_comments)"
        } else {
            return "Comments"
        }
    }
    
    //MARK: - Refreshing
    func startRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(PostsTableViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
    }
    
    func refresh(sender:AnyObject) {
        if let realPost = post, !refreshingInProgress {
            refreshingInProgress = true
            loader.getCommentsForPostWithId(realPost.thing_id, callback: onCommentsDelivered(comments:error:))
        }
    }
    
    /// Loads the post information on initialization.
    func loadPost() {
        if let realPost = post {
            //First, stop all the activity going on in a view (if split view controller is used, this is especially required).
            if let popup = popupWindow, popup.isShown {
                popup.removeAnimate()
            }
            if let popupWeb = popupWebWindow, popupWeb.isShown {
                popupWeb.removeAnimate()
            }
            comments = []
            textLabel.text = realPost.selftext_html ?? ""
            tableView.reloadData()
            hintLabel.isHidden = true
            self.mainImage = nil
            self.imgView.image = #imageLiteral(resourceName: "Placeholder")
            self.imageSpinner.stopAnimating()
            
            //Next, load the new post.
            tableView.refreshControl?.beginRefreshing()
            let domain = realPost.is_self ? "" : "(\(realPost.domain))"
            let mutableString = NSMutableAttributedString(string: "\(realPost.score) \(realPost.title) \(domain)", attributes: nil)
            mutableString.addColorHighlightWith(Configuration.Colors.red, for: String(realPost.score))
            mutableString.addColorHighlightWith(Configuration.Colors.blue, for: domain)
            titleLabel.attributedText = mutableString
            
            if let data = realPost.additionalData {
                downloadImage(from: URL(string: data)!, isGif: true)
            } else {
                if let realImage = realPost.image,
                    let checkedUrl = URL(string: realImage) {
                    downloadImage(from: checkedUrl)
                } else {
                    if !realPost.is_self {
                        hintLabel.isHidden = false
                    }
                }
            }
            refresh(sender: self)
        }
    }
    
    /// Loads the post image from the given url.
    ///
    /// - Parameter url: url with the image
    /// - Parameter isGif: whether it is a gif image
    func downloadImage(from url: URL, isGif: Bool = false) {
        //A requested image could be in a cache.
        if let cachedImage = ImageCache.sharedCache.imageForKey(key: url.absoluteString) {
            self.stopLoadingWith(image: cachedImage)
        } else {
            imageSpinner.startAnimating()
            hintLabel.isHidden = true
            let id = post?.thing_id
            if isGif {
                DispatchQueue.global().async {
                    let gif = UIImage.gif(url: url.absoluteString)
                    DispatchQueue.main.async {
                        if let gifImage = gif {
                            //Check if the loaded image is for the post currently being shown.
                            if id == self.post?.thing_id {
                                self.stopLoadingWith(image: gifImage)
                                ImageCache.sharedCache.setImage(image: gifImage, forKey: url.absoluteString)
                            }
                        }
                    }
                }
            } else {
                WebService().getDataFromUrl(url) { (data, response, error)  in
                    guard let data = data, error == nil else { return }
                    DispatchQueue.main.async() { () -> Void in
                        if let img = UIImage(data: data) {
                            if id == self.post?.thing_id {
                                self.stopLoadingWith(image: img)
                                ImageCache.sharedCache.setImage(image: img, forKey: url.absoluteString)
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// A callback on loaded image or gif. Stops all spinners and loads the image.
    ///
    /// - Parameter image: loaded image
    func stopLoadingWith(image: UIImage) {
        hintLabel.isHidden = true
        self.mainImage = image
        self.imgView.image = image
        self.imgView.contentMode = .scaleAspectFit
        self.imageSpinner.stopAnimating()
    }
    
    /// Opens the post in a browser.
    ///
    /// - Parameter sender: bar button
    @IBAction func viewInBrowser(_ sender: UIBarButtonItem) {
        if let realPost = post {
            if popupWebWindow == nil || !popupWebWindow!.isShown {
                popupWebWindow = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popupweb") as? PopupWebViewController
                popupWebWindow!.urlString = realPost.url
                self.addChildViewController(popupWebWindow!)
                popupWebWindow!.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                self.view.addSubview(popupWebWindow!.view)
                popupWebWindow!.didMove(toParentViewController: self)
            }
        }
    }
    
    //MARK: - Callbacks
    func onCommentsDelivered(comments: [Comment]?, error: Error?) {
        refreshingInProgress = false
        if let receivedComments = comments {
            self.comments = receivedComments
        } else if let caughterror = error {
            displayError(caughterror)
        }
        DispatchQueue.main.sync() {
            tableView.reloadData()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func showComments(_ sender: UIButton) {
        showHideComments.isSelected = !showHideComments.isSelected
        tableView.isHidden = !showHideComments.isSelected
        //Scrolling the scrollview to show the comment list full screen.
        self.scrollView.scrollRectToVisible(showHideComments.isSelected ? tableView.frame : titleLabel.frame, animated: true)
    }
    
    /// Displays an alert with an error.
    ///
    /// - Parameter error: error object
    func displayError(_ error: Error) {
        let errorString = error is RedditError ? RedditError.getDescriptionForError(error as! RedditError) : error.localizedDescription
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
    //MARK: - Post selected delegate
    func postSelected(newPost: LinkM) {
        self.post = newPost
        loadPost()
    }
    
    //MARK: - Navigation
    @IBAction func open(_ sender: UITapGestureRecognizer) {
        if let image = mainImage {
            popupWindow = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popup") as? PopupViewController
            self.addChildViewController(popupWindow!)
            popupWindow!.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.view.addSubview(popupWindow!.view)
            popupWindow!.imgView.image = image
            popupWindow!.imgView.contentMode = .scaleAspectFit
            popupWindow!.didMove(toParentViewController: self)
        }
    }
}

