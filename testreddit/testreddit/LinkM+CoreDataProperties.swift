//
//  LinkM+CoreDataProperties.swift
//  
//
//  Created by Alexander on 6/20/17.
//
//

import Foundation
import CoreData


extension LinkM {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LinkM> {
        return NSFetchRequest<LinkM>(entityName: "LinkM")
    }
    
    /// The title of the link.
    @NSManaged public var title: String
    
    /// The link of this post. The permalink if this is a self-post.
    @NSManaged public var url: String    
    
    /// Score of the link (likes - dislikes).
    @NSManaged public var score: Int32
    
    /// The time of creation in local epoch-second format.
    @NSManaged public var created: Int32
    
    /// The account of the poster.
    @NSManaged public var author: String?
    
    /// The number of comments that belong to this link. Includes removed comments.
    @NSManaged public var num_comments: Int32
    
    /// Full URL to the thumbnail for this link; "self" if this is a self post; "image" if this is a link to an image but has no thumbnail; "default" if a thumbnail is not available.
    @NSManaged public var thumbnail: String
    
    /// The formatted escaped HTML text. This is the HTML formatted version of the marked up text. Null if not present.
    @NSManaged public var selftext_html: String?
    
    /// Id of the post.
    @NSManaged public var thing_id: String
    
    /// The domain of this link. Self posts will be self.<subreddit> while other examples include en.wikipedia.org and s3.amazon.com.
    @NSManaged public var domain: String
    
    /// True if this link is a selfpost.
    @NSManaged public var is_self: Bool
    
    /// Subreddit of thing excluding the /r/ prefix.
    @NSManaged public var subreddit: String
    
    /// Basically an autoicremented property indicating the order of items that came from the server (as we don't know exactly what the sorting algorythm is).
    @NSManaged public var order: Int

}
