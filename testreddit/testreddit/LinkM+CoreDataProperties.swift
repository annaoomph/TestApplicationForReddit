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

    @NSManaged public var title: String
    @NSManaged public var url: String
    @NSManaged public var score: Int32
    @NSManaged public var created: Int32
    @NSManaged public var author: String?
    @NSManaged public var num_comments: Int32
    @NSManaged public var thumbnail: String
    @NSManaged public var selftext_html: String?
    @NSManaged public var id: String
    @NSManaged public var domain: String
    @NSManaged public var is_self: Bool
    @NSManaged public var subreddit: String

}
