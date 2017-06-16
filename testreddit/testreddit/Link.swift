//
//  Link.swift
//  testreddit
//
//  Created by Alexander on 6/15/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation

struct ProperTyKey {
    static let title = "title"
    static let url = "url"
    static let score = "score"
    static let created = "created"
    static let author = "author"
    static let num_comments = "num_comments"
    static let thumbnail = "thumbnail"
    static let selftext_html = "selftext_html"
    static let id = "id"
    static let domain = "domain"
    static let is_self = "is_self"
    static let subreddit = "subreddit"
    static let bigImage = "bigImage"
    static let smallImage = "smallImage"
    
}

public class Link: NSObject, NSCoding {
    
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveUrl = DocumentsDirectory.appendingPathComponent("links")
    
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
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: ProperTyKey.title)
        aCoder.encode(url, forKey: ProperTyKey.url)
        aCoder.encode(score, forKey: ProperTyKey.score)
        aCoder.encode(created, forKey: ProperTyKey.created)
        aCoder.encode(author, forKey: ProperTyKey.author)
        aCoder.encode(num_comments, forKey: ProperTyKey.num_comments)
        aCoder.encode(thumbnail, forKey: ProperTyKey.thumbnail)
        aCoder.encode(selftext_html, forKey: ProperTyKey.selftext_html)
        aCoder.encode(id, forKey: ProperTyKey.id)
        aCoder.encode(domain, forKey: ProperTyKey.domain)
        aCoder.encode(is_self, forKey: ProperTyKey.is_self)
        aCoder.encode(subreddit, forKey: ProperTyKey.subreddit)
        if bigImages.count > 0 {
            aCoder.encode(bigImages[0], forKey: ProperTyKey.bigImage)
            aCoder.encode(smallImages[0], forKey: ProperTyKey.smallImage)
        }
    }
    
    required public init?(coder aCoder: NSCoder) {
        guard let title = aCoder.decodeObject(forKey: ProperTyKey.title) as! String?,
            let url = aCoder.decodeObject(forKey: ProperTyKey.url) as! String?,
            let score = aCoder.decodeObject(forKey: ProperTyKey.score) as! Int?,
            let created = aCoder.decodeObject(forKey: ProperTyKey.created) as! Int?,
            let thumbnail = aCoder.decodeObject(forKey: ProperTyKey.thumbnail) as! String?,
            let num_comments = aCoder.decodeObject(forKey: ProperTyKey.num_comments) as! Int?,
            let domain = aCoder.decodeObject(forKey: ProperTyKey.domain) as! String?,
            let is_self = aCoder.decodeObject(forKey: ProperTyKey.is_self) as! Bool?,
            let subreddit = aCoder.decodeObject(forKey: ProperTyKey.subreddit) as! String?,
            let id = aCoder.decodeObject(forKey: ProperTyKey.id) as! String?
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
        self.id = id
        author = aCoder.decodeObject(forKey: ProperTyKey.author) as? String
        selftext_html = aCoder.decodeObject(forKey: ProperTyKey.selftext_html) as? String
        if let bigImage = aCoder.decodeObject(forKey: ProperTyKey.bigImage) as? String,
            let smallImage = aCoder.decodeObject(forKey: ProperTyKey.smallImage) as? String {
            bigImages.append(bigImage)
            smallImages.append(smallImage)
        }
        super.init()
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
