//
//  CoreDataManager.swift
//  testreddit
//
//  Created by Alexander on 6/20/17.
//  Copyright © 2017 Akvelon. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataManager {
    
    static let instance = CoreDataManager()
    
    var fetchedResultsControllerForPosts: NSFetchedResultsController<LinkM>?
    
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
                try fetchedResultsController().performFetch()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func fetchedResultsController() -> NSFetchedResultsController<LinkM> {
        if (fetchedResultsControllerForPosts == nil) {
            let fetchRequest = NSFetchRequest<LinkM>(entityName: "LinkM")
            let sortDescriptor = NSSortDescriptor(key: "score", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchedResultsControllerForPosts = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        }
        return fetchedResultsControllerForPosts!
    }
    
    //MARK: - Management functions
    
    //
    func getAll() {
        do {
            try fetchedResultsController().performFetch()
        } catch {}
    }
    
    func clear() {
        if let objects = fetchedResultsController().fetchedObjects {
            for object in objects {
                managedObjectContext.delete(object)
            }
            do {
                try managedObjectContext.save()
            } catch {}
        }
    }
    
    func getPostCount() -> Int {
        if let fetchedObjects = fetchedResultsController().fetchedObjects {
            return fetchedObjects.count
        } else {
            return 0
        }
    }
    
    func getPostAt(indexPath: IndexPath) -> LinkM {
        return fetchedResultsController().object(at: indexPath)
    }
}
