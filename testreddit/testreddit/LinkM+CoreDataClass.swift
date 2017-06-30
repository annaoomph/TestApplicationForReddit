//
//  LinkM+CoreDataClass.swift
//
//
//  Created by Alexander on 6/20/17.
//
//

import Foundation
import CoreData
import SwiftyJSON
@objc(LinkM)

/// A class describing a link (or a post) in reddit.
public class LinkM: NSManagedObject {
    
    ///A list of url's to the images connected with the post.
    public var bigImages: [String?] = []
    
    ///A path to additional information from the post (e. g. gifs, videos).
    public var additionalData: String?
    
    /// Creates an instance of the Link and writes it to the core data context.
    ///
    /// - Parameter JSONData: json from the server
    /// - Returns: an object of Link type
    class func create(JSONData: JSON) -> LinkM? {
        let linkM = NSEntityDescription.insertNewObject(forEntityName: "LinkM", into: CoreDataManager.instance.managedObjectContext) as! LinkM
        
        guard let title = JSONData["title"].string,
            let url = JSONData["url"].string,
            let score = JSONData["score"].int32,
            let created = JSONData["created"].int32,
            let thumbnail = JSONData["thumbnail"].string,
            let num_comments = JSONData["num_comments"].int32,
            let domain = JSONData["domain"].string,
            let is_self = JSONData["is_self"].bool,
            let subreddit = JSONData["subreddit"].string,
            let id = JSONData["id"].string
            else {
                return nil
        }
        
        linkM.title = title
        linkM.url = url
        linkM.score = score
        linkM.created = created
        linkM.num_comments = num_comments
        linkM.domain = domain
        linkM.subreddit = subreddit
        linkM.thumbnail = thumbnail
        linkM.is_self = is_self
        linkM.author = JSONData["author"].string
        linkM.selftext_html = JSONData["selftext"].string
        linkM.thing_id = id
        //Here autoincrement the order value.
        linkM.order = CoreDataManager.instance.getLastOrderNumber() + 1
        let images = JSONData["preview"]["images"]
        let enabled = JSONData["preview"]["enabled"].boolValue
        if enabled {
            for (_, image) in images {
                if let bigImage = image["source"]["url"].string {
                    linkM.bigImages.append(bigImage)
                }
                
                if let variants = image["variants"].dictionary {
                    if let gifs = variants["gif"]?["source"]["url"].string {
                        linkM.additionalData = gifs
                        
                    } else {
                        if let mp4 = variants["mp4"]?["source"]["url"].string {
                            linkM.additionalData = mp4
                        }
                    }
                }
                
            }
        }
        return linkM
    }
}
