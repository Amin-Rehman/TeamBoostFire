//
//  HostPersistenceStorage.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation
import CoreData

struct ValueTimeStampPair<T> {
    let value: T
    let timestamp: NSNumber
}

protocol PersistenceStorage {
    func fetchAll() -> [HostPersisted]
    func clear()

    func setMeeting(with meetingIdentifier: String)

    func setMeetingParamsMeetingTime(meetingTime: Int64,
                                     meetingIdentifier: String,
                                     localChange: Bool)
    func meetingParamsMeetingTime(for meetingIdentifier: String) -> ValueTimeStampPair<Int64>

    func setCallToSpeakerInterrupt(callToSpeakerInterrupt: String,
                                   meetingIdentifier: String,
                                   localChange: Bool)
    func callToSpeakerInterrupt(for meetingIdentifier: String) -> ValueTimeStampPair<String>

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


    /**
     setMeeting should always create a new entry in the database and firebase sync
     should only be called once during a meeting
     */
    func setMeeting(with meetingIdentifier: String) {
        let hostPersisted = NSEntityDescription.insertNewObject(
            forEntityName: "HostPersisted",
            into: managedObjectContext) as! HostPersisted

        hostPersisted.meetingIdentifier = meetingIdentifier
        hostPersisted.meetingIdentifierChanged = HostPersistenceStorage.makeCurrentTimestamp()
        managedObjectContext.insert(hostPersisted)
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("Error while insert new entity")
        }
    }

    // MARK: - Meeting Params: Meeting Time
    func setMeetingParamsMeetingTime(meetingTime: Int64,
                                     meetingIdentifier: String,
                                     localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.meetingParamsMeetingTime = meetingTime

            if localChange {
                hostPersisted.meetingParamsMeetingTimeChanged =
                    HostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingParamsMeetingTimeChanged = 0
            }

            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func meetingParamsMeetingTime(for meetingIdentifier: String) -> ValueTimeStampPair<Int64> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                print("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<Int64>(value: 0, timestamp: 0)
            }
            return ValueTimeStampPair<Int64>(value: hostPersisted.meetingParamsMeetingTime,
                                             timestamp: hostPersisted.meetingParamsMeetingTimeChanged ?? 0)
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }

    // MARK: - Call to Speaker Interrupt
    func setCallToSpeakerInterrupt(callToSpeakerInterrupt: String,
                                   meetingIdentifier: String,
                                   localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.callToSpeakerInterrupt = callToSpeakerInterrupt

            if localChange {
                hostPersisted.callToSpeakerInterruptChanged =
                    HostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingParamsMeetingTimeChanged = 0
            }

            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func callToSpeakerInterrupt(for meetingIdentifier: String) -> ValueTimeStampPair<String> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                assertionFailure("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<String>(value: "", timestamp: 0)
            }
            return ValueTimeStampPair<String>(value: hostPersisted.callToSpeakerInterrupt ?? "",
                                             timestamp: hostPersisted.callToSpeakerInterruptChanged ?? 0)
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }    

    // MARK: - Current Speaker Speaking Time
    func setCurrentSpeakerSpeakingTime(currentSpeakerSpeakingTime: Int64,
                                       meetingIdentifier: String,
                                       localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.currentSpeakerSpeakingTime = currentSpeakerSpeakingTime

            if localChange {
                hostPersisted.currentSpeakerSpeakingTimeChanged =
                    HostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.currentSpeakerSpeakingTimeChanged = 0
            }

            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func currentSpeakerSpeakingTime(for meetingIdentifier: String) -> ValueTimeStampPair<Int64> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                assertionFailure("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<Int64>(value: 0, timestamp: 0)
            }
            return ValueTimeStampPair<Int64>(value: hostPersisted.currentSpeakerSpeakingTime,
                                             timestamp: hostPersisted.currentSpeakerSpeakingTimeChanged ?? 0)
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }
}

extension HostPersistenceStorage {

    static private func makeCurrentTimestamp() -> NSNumber {
        return NSNumber(value: Date().timeIntervalSinceReferenceDate)
    }

    private func fetchHostPersisted(with meetingIdentifier: String) throws -> HostPersisted? {
        let fetchRequest = NSFetchRequest<HostPersisted>(entityName: HostPersisted.entityName)
        fetchRequest.predicate = NSPredicate(format: "meetingIdentifier == %@", meetingIdentifier)
        let fetchResults = try managedObjectContext.fetch(fetchRequest)
        return fetchResults.first
    }
}
