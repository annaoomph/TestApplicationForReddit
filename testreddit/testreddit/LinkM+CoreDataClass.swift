//
//  LinkM+CoreDataClass.swift
//  
//
//  Created by Alexander on 6/20/17.
//
//

import Foundation
import CoreData

@objc(LinkM)

/// A class describing a link (or a post) in reddit.
public class LinkM: NSManagedObject {    
    
    //A list of url's to the images connected with the post.
    public var bigImages: [String?] = []
    //A list of url's to the small resolution images connected with the post.
    public var smallImages: [String?] = []
    
    public var additionalData: String?
    
    class func create(JSONData: NSDictionary!) -> LinkM? {
        let linkM = NSEntityDescription.insertNewObject(forEntityName: "LinkM", into: CoreDataManager.instance.managedObjectContext) as! LinkM
        
        guard let title = JSONData["title"] as! String?,
            let url = JSONData["url"] as! String?,
            let score = JSONData["score"] as! Int32?,
            let created = JSONData["created"] as! Int32?,
            let thumbnail = JSONData["thumbnail"] as! String?,
            let num_comments = JSONData["num_comments"] as! Int32?,
            let domain = JSONData["domain"] as! String?,
            let is_self = JSONData["is_self"] as! Bool?,
            let subreddit = JSONData["subreddit"] as! String?,
            let id = JSONData["id"] as! String?
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
        linkM.author = JSONData["author"] as? String
        linkM.selftext_html = JSONData["selftext_html"] as? String
        linkM.id = id
        if let preview = JSONData["preview"] as! NSDictionary?,
            let images = preview["images"] as! [NSDictionary]? {
            
            for image in images {
                if let bigImage = image["source"] as! NSDictionary? {
                    if let imageUrl = bigImage["url"] as! String? {
                        linkM.bigImages.append(imageUrl)
                    }
                }
                if let resolutions = image["resolutions"] as! [NSDictionary]? {
                    if resolutions.count > 0 {
                    if let smallImage = resolutions[0]["url"] as! String? {
                        linkM.smallImages.append(smallImage)
                    }
                    }
                }
                if (linkM.bigImages.count < linkM.smallImages.count) {
                    linkM.bigImages.append(nil)
                }
                if (linkM.bigImages.count > linkM.smallImages.count) {
                    linkM.smallImages.append(nil)
                }
                if let variants = image["variants"] as! NSDictionary? {
                    if let gifs = variants["gif"] as! NSDictionary? {
                        if let gifSource = gifs["source"] as! NSDictionary? {
                            if let gifUrl = gifSource["url"] as! String? {
                                linkM.additionalData = gifUrl
                            }
                        }
                    } else
                        if let mp4 = variants["mp4"] as! NSDictionary? {
                            if let mp4Source = mp4["source"] as! NSDictionary? {
                                if let mp4Url = mp4Source["url"] as! String? {
                                    linkM.additionalData = mp4Url
                                }
                            }
                    }
                    
                }
            }
            
        }
        return linkM
    }

}
