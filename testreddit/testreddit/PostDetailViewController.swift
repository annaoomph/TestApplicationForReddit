//
//  ViewController.swift
//  testreddit
//
//  Created by Alexander on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit
import SwiftGifOrigin


/// A controller for the post view.
class PostDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostSelectionDelegate {
    
    //MARK: - Storyboard elements
    /// A view with the post image or gif.
    @IBOutlet weak var imgView: UIImageView!
    
    /// An activity indicator that shows that imnage or gif is still loading.
    @IBOutlet weak var imageSpinner: UIActivityIndicatorView!
    
    /// Table for comments.
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textLabel: UILabel!
    /// Title of the post.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Label saying that the post looks better in a browser.
    @IBOutlet weak var hintLabel: UILabel!
    
    //MARK: - Properties
    /// Loads data from server.
    let loader = Loader()
    
    /// Image or gif connected with the post.
    var mainImage: UIImage?
    
    /// Shown post (link).
    var post: LinkM?
    
    var popupWindow: PopupViewController?
    
    /// A list of comments for the shown post.
    var comments: [Comment] = []
    
    /// Whether the request to server is still loading.
    var refreshingInProgress = false
    
    
    func postSelected(newPost: LinkM) {
        self.post = newPost
        loadPost()
    }
    
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
        CommentUtils().markComments(commentToMark: indexPath.row, comments: comments)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let cellsCount = CommentUtils().countComments(initialCount: 0, comments: comments)
        return cellsCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentTableViewCell else {
            fatalError("Not loaded cell")
        }
        let (level, returnedComment) = CommentUtils().findComment(indexOfTheComment: indexPath.row, level: -1, comments: comments)
        
        if let comment = returnedComment {
            cell.constructLabels(comment: comment, level: level)
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
        tableView.refreshControl!.addTarget(self, action: #selector(PostsTableViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
    }
    
    func refresh(sender:AnyObject) {
        if let realPost = post, !refreshingInProgress {
            refreshingInProgress = true
            loader.getComments(postId: realPost.thing_id, callback: onCommentsDelivered(comments:error:))
        }
    }
    
    /// Loads the post information on initialization.
    func loadPost() {
        if let realPost = post {
            if let popup = popupWindow, popup.isShown {
                popup.removeAnimate()
            }
            comments = []
            textLabel.text = realPost.selftext_html ?? ""
            
            tableView.reloadData()
            hintLabel.isHidden = true
            self.mainImage = nil
            self.imgView.image = #imageLiteral(resourceName: "Placeholder")
            self.imageSpinner.stopAnimating()
            tableView.refreshControl!.beginRefreshing()
            let domain = realPost.is_self ? "" : "(\(realPost.domain))"
            let mutableString = NSMutableAttributedString(string: "\(realPost.score) \(realPost.title) \(domain)", attributes: nil)
            mutableString.addAttribute(NSForegroundColorAttributeName, value: Configuration.Colors.red, range: NSRange(location: 0, length:"\(realPost.score)".characters.count))
            mutableString.addAttribute(NSForegroundColorAttributeName, value: Configuration.Colors.blue, range: NSRange(location: mutableString.length - domain.characters.count, length:domain.characters.count))
            titleLabel.attributedText = mutableString
            
            if let data = realPost.additionalData {
                downloadImage(url: URL(string: data)!, isGif: true)
            } else {
                if realPost.bigImages.count > 0,
                    let checkedUrl = URL(string: (realPost.bigImages[0])!) {
                    downloadImage(url: checkedUrl)
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
    func downloadImage(url: URL, isGif: Bool = false) {
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
                            self.stopLoading(image: gifImage)
                        }
                    }
                }
            }
        } else {
            WebService().getDataFromUrl(url: url) { (data, response, error)  in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() { () -> Void in
                    if let img = UIImage(data: data) {
                        if id == self.post?.thing_id {
                            self.stopLoading(image: img)
                        }
                    }
                }
            }
        }
    }
    
    /// A callback on loaded image or gif. Stops all spinners and loads the image.
    ///
    /// - Parameter image: loaded image
    func stopLoading(image: UIImage) {
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
        if let loadedPost = post, let url = URL(string: loadedPost.url) {
            UIApplication.shared.open(url, options: [:])
        }
    }
    
    //MARK: - Callbacks
    func onCommentsDelivered(comments: [Comment]?, error: Error?) {
        refreshingInProgress = false
        if let receivedComments = comments {
            self.comments = receivedComments
        } else if let caughterror = error {
            displayError(error: caughterror)
        }
        DispatchQueue.main.sync() {
            tableView.reloadData()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    /// Displays an alert with an error.
    ///
    /// - Parameter error: error object
    func displayError(error: Error) {
        let errorString = error is RedditError ? ErrorHandler.getDescriptionForError(error: error as! RedditError) : error.localizedDescription
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
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

