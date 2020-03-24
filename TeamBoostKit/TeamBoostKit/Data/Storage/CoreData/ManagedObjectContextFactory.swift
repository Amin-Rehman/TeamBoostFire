//
//  ManagedObjectContextFactory.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 04.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation
import CoreData

struct ManagedObjectContextFactory {
    static public func make() -> NSManagedObjectContext {
        guard let modelURL = Bundle.main.url(
            forResource: "TeamBoostDataModel",
            withExtension:"momd") else {
                fatalError("Error loading model from bundle")
        }

        // 1: Setup the managed object model
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error loading managed object model")
        }

        // 2: Setup the store coordinator
        let storeCoordinator = NSPersistentStoreCoordinator(
            managedObjectModel: managedObjectModel)
        do {
            try storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                                    configurationName: nil,
                                                    at: nil,
                                                    options: nil)
        } catch {
            fatalError("Error adding persistent store to coordinator: \(error)")
        }

        // 3: Setup managed object context with its coordinator
        let managedObjectContext = NSManagedObjectContext(
            concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        return managedObjectContext
    }
}
