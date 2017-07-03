//
//  PostCellTableViewCell.swift
//  testreddit
//
//  Created by Alexander on 6/16/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    /// A view for the preview image (thumbnail).
    @IBOutlet weak var imgView: UIImageView!
    
    /// A label with post score.
    @IBOutlet weak var scoreLabel: UILabel!
    
    /// A label with the title.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// A label with additional information about the post (like creation time, author, etc).
    @IBOutlet weak var infoLabel: UILabel!
    
    /// Id of the post connected with the cell.
    var postId: String?
    
    /// Starts async loading the image for the cell and displays it when ready.
    ///
    /// - Parameter url: url of the image
    func downloadImage(url: URL) {
        self.imgView.image = #imageLiteral(resourceName: "Placeholder")
        let thisImageView = self.imgView!
        let currentPostId = postId ?? ""
        WebService().getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                //We should not attach this image to any other post cel except the one we have been downloading it for.
                //That's why we need to check if id of the current cell matches with the id of the cell this image is intended for.
                if self.postId == currentPostId {
                    thisImageView.image = UIImage(data: data)
                    thisImageView.contentMode = .scaleAspectFit
                }
            }
        }
    }
    
    
    /// Constructs the text on all the call labels.
    ///
    /// - Parameter post: the post itself.
    func constructLabels(post: LinkM) {
        postId = post.thing_id
        titleLabel.text = post.title
        scoreLabel.text = "\(post.score)"
        scoreLabel.textColor = Configuration.Colors.red
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
            infoLabel.attributedText = mutableString
        }
    }
}
