//
//  CoreDataController.swift
//  RealHome
//
//  Created by boqian cheng on 2017-10-10.
//  Copyright © 2017 boqiancheng. All rights reserved.
//

import Foundation
import CoreData

class CoreDataController {
    
    // to prevent other creating this object by accident, because is private init()
    
    private init() {
        
    }
    
    // MARK: - Core Data stack
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "RealHome")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    class func getContext() -> NSManagedObjectContext {
        return CoreDataController.persistentContainer.viewContext
    }
    
    // for entity "agentGroup"
    
    class func createAgentGroupEntity(groupID: String) -> NSManagedObject {
        
        let context = CoreDataController.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "AgentGroup", in: context)!
        
        let agentH = NSManagedObject(entity: entity, insertInto: context)
        agentH.setValue(groupID, forKeyPath: "groupID")
        
        CoreDataController.saveContext()
        
        return agentH
    }
    
    class func fetchAgentGroups() -> [NSManagedObject] {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AgentGroup")
        
        var agentGroups: [NSManagedObject] = []
        do {
            agentGroups = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return agentGroups
    }
    
    class func deleteAgentGroupEntity(groupID: String) {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AgentGroup")
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "groupID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Add Predicate  ([c]) means character
   //     let predicate = NSPredicate(format: "groupID CONTAINS[c] %@", "o")
    //    let bobPredicate = NSPredicate(format: "firstName = 'Bob'")
    //    let smithPredicate = NSPredicate(format: "lastName = %@", "Smith")
    //    let thirtiesPredicate = NSPredicate(format: "age >= 30")
        let predicate = NSPredicate.init(format: "groupID == %@", groupID)
        fetchRequest.predicate = predicate
        
        var agentH: [NSManagedObject] = []
        do {
            agentH = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for obj in agentH {
            context.delete(obj)
        }
        
        CoreDataController.saveContext()
    }
    
    class func isAgentGroupExisted(groupID: String) -> Bool {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AgentGroup")
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "groupID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate.init(format: "groupID == %@", groupID)
        fetchRequest.predicate = predicate
        
        var agentH: [NSManagedObject] = []
        do {
            agentH = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if agentH.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    class func deleteAgentGroupAll() {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AgentGroup")
        
        var agentH: [NSManagedObject] = []
        do {
            agentH = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for obj in agentH {
            context.delete(obj)
        }
        
        CoreDataController.saveContext()
    }
    
    // for entity "agentGroupBuyer"
    
    class func createAgentGroupEntityBuyer(groupID: String) -> NSManagedObject {
        
        let context = CoreDataController.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "AgentGroupBuyer", in: context)!
        
        let agentH = NSManagedObject(entity: entity, insertInto: context)
        agentH.setValue(groupID, forKeyPath: "groupID")
        
        CoreDataController.saveContext()
        
        return agentH
    }
    
    class func fetchAgentGroupsBuyer() -> [NSManagedObject] {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AgentGroupBuyer")
        
        var agentGroups: [NSManagedObject] = []
        do {
            agentGroups = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return agentGroups
    }
    
    class func deleteAgentGroupEntityBuyer(groupID: String) {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AgentGroupBuyer")
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "groupID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Add Predicate  ([c]) means character
        //     let predicate = NSPredicate(format: "groupID CONTAINS[c] %@", "o")
        //    let bobPredicate = NSPredicate(format: "firstName = 'Bob'")
        //    let smithPredicate = NSPredicate(format: "lastName = %@", "Smith")
        //    let thirtiesPredicate = NSPredicate(format: "age >= 30")
        let predicate = NSPredicate.init(format: "groupID == %@", groupID)
        fetchRequest.predicate = predicate
        
        var agentH: [NSManagedObject] = []
        do {
            agentH = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for obj in agentH {
            context.delete(obj)
        }
        
        CoreDataController.saveContext()
    }
    
    class func isAgentGroupExistedBuyer(groupID: String) -> Bool {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AgentGroupBuyer")
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "groupID", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let predicate = NSPredicate.init(format: "groupID == %@", groupID)
        fetchRequest.predicate = predicate
        
        var agentH: [NSManagedObject] = []
        do {
            agentH = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        if agentH.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    class func deleteAgentGroupAllBuyer() {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AgentGroupBuyer")
        
        var agentH: [NSManagedObject] = []
        do {
            agentH = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for obj in agentH {
            context.delete(obj)
        }
        
        CoreDataController.saveContext()
    }
    
    // for entity "favorite"
    
    class func createFavoriteEntity(listID: String, resiComm: String) -> NSManagedObject {
        
        let context = CoreDataController.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FavoriteProp", in: context)!
        
        let favoriteH = NSManagedObject(entity: entity, insertInto: context)
        favoriteH.setValue(listID, forKeyPath: "listingID")
        favoriteH.setValue(resiComm, forKeyPath: "resiComm")
        
        CoreDataController.saveContext()
        
        return favoriteH
    }
    
    class func fetchFavoriteProps() -> [NSManagedObject] {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteProp")
        
        var favoriteProps: [NSManagedObject] = []
        do {
            favoriteProps = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return favoriteProps
    }
    
    class func deleteFavoriteEntity(listID: String) {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteProp")
        
        // Add Sort Descriptor
    //    let sortDescriptor = NSSortDescriptor(key: "listingID", ascending: true)
    //    fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Add Predicate  ([c]) means character
        //     let predicate = NSPredicate(format: "groupID CONTAINS[c] %@", "o")
        //    let bobPredicate = NSPredicate(format: "firstName = 'Bob'")
        //    let smithPredicate = NSPredicate(format: "lastName = %@", "Smith")
        //    let thirtiesPredicate = NSPredicate(format: "age >= 30")
        let predicate = NSPredicate.init(format: "listingID == %@", listID)
        fetchRequest.predicate = predicate
        var favoriteH: [NSManagedObject] = []
        do {
            favoriteH = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for obj in favoriteH {
            context.delete(obj)
        }
        
        CoreDataController.saveContext()
    }
    
    class func deleteFavoritePropsAll() {
        
        let context = CoreDataController.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FavoriteProp")
        
        var favoriteH: [NSManagedObject] = []
        do {
            favoriteH = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for obj in favoriteH {
            context.delete(obj)
        }
        
        CoreDataController.saveContext()
    }
    
    // MARK: - Core Data Saving support
    
    class func saveContext () {
        
        let context = CoreDataController.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    class func className() -> String {
        return String(describing: CoreDataController.self)
     //   return String(describing: AuthorizationVC.self)
    }
}
