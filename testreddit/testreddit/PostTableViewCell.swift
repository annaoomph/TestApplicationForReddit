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
        if let cachedImage = ImageCache.sharedCache.imageForKey(key: url.absoluteString) {
            self.imgView.image = cachedImage
            self.imgView.contentMode = .scaleAspectFit
        } else {
            self.imgView.image = #imageLiteral(resourceName: "Placeholder")
            let thisImageView = self.imgView!
            let currentPostId = postId ?? ""
            WebService().getDataFromUrl(url) { (data, response, error)  in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async() { () -> Void in
                    //We should not attach this image to any other post cel except the one we have been downloading it for.
                    //That's why we need to check if id of the current cell matches with the id of the cell this image is intended for.
                    if self.postId == currentPostId {
                        let img = UIImage(data: data)
                        thisImageView.image = img
                        ImageCache.sharedCache.setImage(image: img!, forKey: url.absoluteString)
                        thisImageView.contentMode = .scaleAspectFit
                    }
                }
            }
        }
    }
    
    
    /// Constructs the text on all the call labels.
    ///
    /// - Parameter post: the post itself.
    /// - Parameter searchString: a filter string, if present.
    func constructLabels(with post: LinkM, searchString: String? = nil) {
        postId = post.thing_id
        var mutableTitle = NSMutableAttributedString(string: post.title, attributes: nil)
        //If the search was performed, highlight the match of the filter text with title text.
        if let search = searchString {
            StringUtils.addHighlightWith(UIFont.boldSystemFont(ofSize: titleLabel.font.pointSize), in: &mutableTitle, for: search)
        }
        titleLabel.attributedText = mutableTitle
        
        scoreLabel.text = "\(post.score)"
        scoreLabel.textColor = Configuration.Colors.red
        let date = DateFormatter.localizedString(from: Date(timeIntervalSince1970: TimeInterval(post.created)), dateStyle: DateFormatter.Style.short, timeStyle: DateFormatter.Style.short)
        //Building colored info string.
        if let author = post.author {
            let domain = post.is_self ? "" : "at \(post.domain)"
            var mutableString = NSMutableAttributedString(string: "Submitted at \(date) by \(author) to \(post.subreddit) \(domain)", attributes: nil)
            StringUtils.addColorHighlightWith(Configuration.Colors.green, in: &mutableString, for: date)
            StringUtils.addColorHighlightWith(Configuration.Colors.blue, in: &mutableString, for: author)
            StringUtils.addColorHighlightWith(Configuration.Colors.orange, in: &mutableString, for: post.subreddit)
            
            if domain.characters.count > 0 {
                StringUtils.addColorHighlightWith(Configuration.Colors.red, in: &mutableString, for: domain)
            }
            
            infoLabel.attributedText = mutableString
        }
    }
}
