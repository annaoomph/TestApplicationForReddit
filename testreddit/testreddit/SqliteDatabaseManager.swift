//
//  SqliteHelper.swift
//  testreddit
//
//  Created by Alexander on 6/16/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import SQLite

class SqliteDatabaseManager {
    
    let links = Table("links")
    
    let id = Expression<Int64>("id")
    let title = Expression<String>("title")
    let url = Expression<String>("url")
    let score = Expression<Int>("score")
    let created = Expression<Int>("created")
    let author = Expression<String?>("author")
    let num_comments = Expression<Int>("num_comments")
    let thumbnail = Expression<String>("thumbnail")
    let selftext_html = Expression<String?>("selftext_html")
    let article_id = Expression<String>("article_id")
    let domain = Expression<String>("domain")
    let is_self = Expression<Bool>("is_self")
    let subreddit = Expression<String>("subreddit")
    let bigImage = Expression<String?>("bigImage")
    let smallImage = Expression<String?>("smallImage")
    var path: String
    
    init() {
        path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true).first!
        if !PreferenceManager().dbInitialized() {
            if initializeDatabase() {
                PreferenceManager().setDbInitialized()
            }
        }
    }
    
    private func initializeDatabase() -> Bool {        
        do {
            let db = try Connection("\(path)/db.sqlite3")
            
            try db.run(links.create { t in
                t.column(id, primaryKey: true)
                t.column(title)
                t.column(url)
                t.column(score)
                t.column(created)
                t.column(author)
                t.column(num_comments)
                t.column(thumbnail)
                t.column(selftext_html)
                t.column(article_id)
                t.column(domain)
                t.column(is_self)
                t.column(subreddit)
                t.column(bigImage)
                t.column(smallImage)
            })
        } catch {
            return false
        }
        return true
    }
    
    func getAllPosts() -> [Link]? {
        var posts: [Link] = []
        do {
            let db = try Connection("\(path)/db.sqlite3")
            for link in try db.prepare(links) {
                
                let post = Link(title: link[title], url: link[url], score: link[score], created: link[created], author: link[author], num_comments: link[num_comments], thumbnail: link[thumbnail], selftext_html: link[selftext_html], id: link[article_id], domain: link[domain], is_self: link[is_self], subreddit: link[subreddit], bigImage: link[bigImage], smallImage: link[smallImage])
                
                posts.append(post)
            }
        } catch {
            return nil
        }
        return posts
        
    }
    
    func deleteAllPosts() -> Bool {
        do {
            let db = try Connection("\(path)/db.sqlite3")
            try db.run(links.delete())
        } catch {
            return false
        }
        return true
    }
    
    func savePosts(posts: [Link]) -> Bool {
        do {
            let db = try Connection("\(path)/db.sqlite3")
            for post in posts {
                
                let insert = links.insert(title <- post.title, url <- post.url, score <- post.score, created <- post.created, author <- post.author, num_comments <- post.num_comments, thumbnail <- post.thumbnail, selftext_html <- post.selftext_html, article_id <- post.id, domain <- post.domain, is_self <- post.is_self, subreddit <- post.subreddit, bigImage <- post.bigImages.count > 0 ? post.bigImages[0] : nil, smallImage <- post.smallImages.count > 0 ? post.smallImages[0] : nil)
                try db.run(insert)
                
            }
        } catch {
            return false
        }
        return true
    }
}
