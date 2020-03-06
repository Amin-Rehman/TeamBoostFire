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

    func setMeetingParamsMeetingTime(meetingTime: Int64,
                                     meetingIdentifier: String,
                                     localChange: Bool)
    func meetingParamsMeetingTime(for meetingIdentifier: String) -> Int64

}

struct HostPersistenceStorage: PersistenceStorage {

    let managedObjectContext: NSManagedObjectContext

    func fetchAll() -> [HostPersisted] {
        do {
            let fetchRequest = NSFetchRequest<HostPersisted>(entityName: HostPersisted.entityName)
            return try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalError("Error fetching all hosts")
        }
    }

    func clear() {
        // TODO: Implement
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


    func setMeetingParamsMeetingTime(meetingTime: Int64,
                                     meetingIdentifier: String,
                                     localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.meetingParamsMeetingTime = meetingTime
            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func meetingParamsMeetingTime(for meetingIdentifier: String) -> Int64 {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                print("Persisted object with meeting identifier not found")
                return 0
            }
            return hostPersisted.meetingParamsMeetingTime
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }
}

extension HostPersistenceStorage {
    private func fetchHostPersisted(with meetingIdentifier: String) throws -> HostPersisted? {
        let fetchRequest = NSFetchRequest<HostPersisted>(entityName: HostPersisted.entityName)
        fetchRequest.predicate = NSPredicate(format: "meetingIdentifier == %@", meetingIdentifier)
        let fetchResults = try managedObjectContext.fetch(fetchRequest)
        return fetchResults.first
    }
}
