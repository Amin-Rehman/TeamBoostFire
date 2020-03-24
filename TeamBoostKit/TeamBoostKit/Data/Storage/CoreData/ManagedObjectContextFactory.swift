//
//  ManagedObjectContextFactory.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 04.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation
import CoreData

enum StorageType {
    case inMemory
    case onDisk
}

struct ManagedObjectContextFactory {
    static public func make(storageType: StorageType) -> NSManagedObjectContext {
        guard let teamBoostKitBundle = Bundle(identifier: "yaberwock.TeamBoostKit") else {
            fatalError("Unable to load TeamBoostKit Bundle")
        }

        guard let modelURL = teamBoostKitBundle.url(
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
            switch storageType {
            case .inMemory:
                try storeCoordinator.addPersistentStore(ofType: NSInMemoryStoreType,
                                                        configurationName: nil,
                                                        at: nil,
                                                        options: nil)
            case.onDisk:
                let fileManager = FileManager.default
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last
                let storeURL = documentsURL?.appendingPathComponent("TeamBoostModel.sqlite")
                try storeCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                        configurationName: nil,
                                                        at: storeURL,
                                                        options: nil)                
            }
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
