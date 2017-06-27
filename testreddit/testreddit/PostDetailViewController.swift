//
//  ViewController.swift
//  testreddit
//
//  Created by Alexander on 6/13/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit


/// A controller for the post view.
class PostDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var imgView: UIImageView!
    
    /// Shown post (link).
    var post: LinkM?
    /// A list of comments for the shown post.
    var comments: [Comment] = []
    
    let loader = Loader()
    var mainImage: UIImage?
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
    
    @IBAction func open(_ sender: UITapGestureRecognizer) {
        if let image = mainImage {
            let popupWindow = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "popup") as! PopupViewController
            self.addChildViewController(popupWindow)
            popupWindow.view.frame = self.view.frame
            self.view.addSubview(popupWindow.view)
            popupWindow.imgView.image = image
            popupWindow.didMove(toParentViewController: self)
        }
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
        var mark = "  "
        var repliesText = "0"
        if let comment = returnedComment {
            cell.titleLabel.text = comment.body
            if let replies = comment.replies,
                replies.count > 0 {
                mark = ">"
                repliesText = "\(replies.count)"
            }
                let myMutableString = NSMutableAttributedString(string: "\(comment.author) replies: \(repliesText)", attributes: nil)
                myMutableString.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 135/255, green: 234/255, blue: 162/255, alpha: 1), range: NSRange(location: 0, length:comment.author.characters.count))
            
              
        cell.infoLabel.attributedText = myMutableString
            

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
            if realPost.bigImages.count > 0,
                let checkedUrl = URL(string: (realPost.bigImages[0])!) {
                imgView.contentMode = .scaleAspectFit
                downloadImage(url: checkedUrl)
            }
            loader.getComments(postId: realPost.id, callback: onCommentsDelivered(comments:error:))
        }
    }
    
    
    
    func downloadImage(url: URL) {
        WebService().getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            DispatchQueue.main.async() { () -> Void in
                if let img = UIImage(data: data) {
                self.imgView.image = img
                self.mainImage = img
                }
            }
        }
    }
    
    //MARK: - Callbacks
    func onCommentsDelivered(comments: [Comment]?, error: String?) {
        if let receivedComments = comments {
            self.comments = receivedComments
        } else if let errorString = error {
            displayError(errorString: errorString)
        }
        DispatchQueue.main.sync() {
            tableView.reloadData()
            tableView.refreshControl?.endRefreshing()
        }
    }
    
    func displayError(errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion:nil)
    }
    
}

