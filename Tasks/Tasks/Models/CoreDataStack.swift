//
//  CoreDataStack.swift
//  Tasks
//
//  Created by Alfredo Colon on 7/8/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import CoreData
import Foundation

class CoreDataStack {
    
    //MARK: - Properties
    
    static let shared = CoreDataStack()
    
    var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Tasks")
        //Take container object and run the loadPersistentStore method on it
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        
        return container
    }()
    
    var mainContext: NSManagedObjectContext { return self.container.viewContext }
}
