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
   
    
    /// Starts async loading the image for the cell and displays it when ready.
    ///
    /// - Parameter url: url of the image
    func downloadImage(url: URL) {
        self.imgView.image = nil
        WebService().getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() { () -> Void in
                self.imgView.image = UIImage(data: data)
                self.imgView.contentMode = .scaleAspectFit
            }
        }
    }
}
