//
//  CoreDataManager.swift
//  testreddit
//
//  Created by Anna on 6/20/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager {
    
    static let instance = CoreDataManager()
    
    private init() {
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    func entityForName(entityName: String) -> NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: entityName, in: self.managedObjectContext)!
    }
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "RedditDataModel", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    /// Clears cache in the database.
    func clear() {
        let fetchRequest = NSFetchRequest<LinkM>(entityName: "LinkM")
        do {
            let objects = try managedObjectContext.fetch(fetchRequest)
            for object in objects {
                managedObjectContext.delete(object)
            }
            try managedObjectContext.save()
        } catch {}
        
    }
    
    /// Gets the id of the last post in a database.
    ///
    /// - Returns: id string
    func getLastPostId() -> String? {
        let fetchRequest = NSFetchRequest<LinkM>(entityName: "LinkM")
        let sort = NSSortDescriptor (key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let objects = try managedObjectContext.fetch(fetchRequest)
            return objects.last?.thing_id
        } catch {
            return nil
        }
    }
    
    /// Gets the last post order number.
    ///
    /// - Returns: order number
    func getLastOrderNumber() -> Int {
        let fetchRequest = NSFetchRequest<LinkM>(entityName: "LinkM")
        let sort = NSSortDescriptor (key: "order", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let objects = try managedObjectContext.fetch(fetchRequest)
            return objects.last?.order ?? 0
        } catch {
            return 0
        }
    }
}
