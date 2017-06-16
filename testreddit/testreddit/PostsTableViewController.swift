//
//  PostsTableViewController.swift
//  testreddit
//
//  Created by Alexander on 6/16/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class PostsTableViewController: UITableViewController, HotPostsDelegate {

    var postsList = [Link]()
    
    var indicator = UIActivityIndicatorView()
 
    
    func activityIndicator() {
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator()
        indicator.startAnimating()
        indicator.backgroundColor = UIColor.white
        HotPostsSession().requestPosts(callback: self)
        refreshControl = UIRefreshControl()
        refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl!.addTarget(self, action: #selector(PostsTableViewController.refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView.addSubview(refreshControl!)
    }

    func refresh(sender:AnyObject) {
        HotPostsSession().requestPosts(callback: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCellTableViewCell else {
            fatalError("Not loaded cell")
        }
        let post = postsList[indexPath.row]
                
        cell.titleLabel.text = post.title
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: HotPostsDelegate
    
    func onPostsDelivered(posts: [Link]) {
        postsList = posts
        DispatchQueue.main.sync() {
            tableView.reloadData()
            refreshControl!.endRefreshing()
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
        }
    }
    
    func onError(error: String) {
        DispatchQueue.main.sync() {
            refreshControl!.endRefreshing()
            indicator.stopAnimating()
            indicator.hidesWhenStopped = true
        }
    }
    
    
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
