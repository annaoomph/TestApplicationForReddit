//
//  Link.swift
//  testreddit
//
//  Created by Alexander on 6/15/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

public class Link: NSObject {
    
    var title: String
    var url: String
    var score: Int
    var created: Int
    var author: String?
    var num_comments: Int
    var thumbnail: String
    var selftext_html: String?
    var id: String
    var domain: String
    var is_self: Bool
    var subreddit: String
    var bigImages: [String?] = []
    var smallImages: [String?] = []
    
    public init(title: String, url: String, score: Int, created: Int, author: String?, num_comments: Int, thumbnail: String, selftext_html: String?, id: String, domain: String, is_self: Bool,
                subreddit: String, bigImage: String?, smallImage: String?) {
        self.title = title
        self.url = url
        self.score = score
        self.created = created
        self.num_comments = num_comments
        self.domain = domain
        self.subreddit = subreddit
        self.thumbnail = thumbnail
        self.is_self = is_self
        self.id = id
        self.author = author
        self.selftext_html = selftext_html
        if bigImage != nil, smallImage != nil {
            bigImages.append(bigImage)
            smallImages.append(smallImage)
        }
    }
    
    init?(JSONData: NSDictionary!) {
        guard let title = JSONData["title"] as! String?,
            let url = JSONData["url"] as! String?,
            let score = JSONData["score"] as! Int?,
            let created = JSONData["created"] as! Int?,
            let thumbnail = JSONData["thumbnail"] as! String?,
            let num_comments = JSONData["num_comments"] as! Int?,
            let domain = JSONData["domain"] as! String?,
            let is_self = JSONData["is_self"] as! Bool?,
            let subreddit = JSONData["subreddit"] as! String?,
            let id = JSONData["id"] as! String?
            else {
                return nil
        }
        
        self.title = title
        self.url = url
        self.score = score
        self.created = created
        self.num_comments = num_comments
        self.domain = domain
        self.subreddit = subreddit
        self.thumbnail = thumbnail
        self.is_self = is_self
        self.author = JSONData["author"] as? String
        self.selftext_html = JSONData["selftext_html"] as? String
        self.id = id
        if let preview = JSONData["preview"] as! NSDictionary?,
            let images = preview["images"] as! [NSDictionary]? {
            
            for image in images {
                if let bigImage = image["source"] as! NSDictionary? {
                    if let imageUrl = bigImage["url"] as! String? {
                        self.bigImages.append(imageUrl)
                    }
                }
                if let resolutions = image["resolutions"] as! [NSDictionary]? {
                    if let smallImage = resolutions[0]["url"] as! String? {
                        self.smallImages.append(smallImage)
                    }
                }
                if (bigImages.count < smallImages.count) {
                    bigImages.append(nil)
                }
                if (bigImages.count > smallImages.count) {
                    smallImages.append(nil)
                }
            }
        }
        super.init()
    }
}
