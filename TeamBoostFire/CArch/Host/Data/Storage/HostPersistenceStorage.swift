//
//  HostPersistenceStorage.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation
import CoreData


protocol PersistenceStorage {
    func insertNewEntity(with meetingIdentifier: String)
    func fetchAll() -> [HostPersisted]
    func clear()
}

struct HostPersistenceStorage: PersistenceStorage {
    let managedObjectContext: NSManagedObjectContext
    let entityName = "HostPersisted"

    func fetchAll() -> [HostPersisted] {
        do {
            return try managedObjectContext.fetch(HostPersisted.fetchRequest())
        } catch {
            fatalError("Error fetching all hosts")
        }
    }

    func insertNewEntity(with meetingIdentifier: String) {
        let hostPersisted = NSEntityDescription.insertNewObject(
            forEntityName: "HostPersisted",
            into: managedObjectContext) as! HostPersisted

        hostPersisted.meetingIdentifier = meetingIdentifier
        managedObjectContext.insert(hostPersisted)
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Error while insert new entity")
        }
    }


    func setValue(value: Any, field: String) {
        // To implement
    }

    func clear() {
        // To Implement
    }
}
