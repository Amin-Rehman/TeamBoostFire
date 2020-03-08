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

    func setMeetingParamsAgenda(agenda: String,
                                meetingIdentifier: String,
                                localChange: Bool)
    func meetingParamsAgenda(for meetingIdentifier: String) -> ValueTimeStampPair<String>

    func setCallToSpeakerInterrupt(callToSpeakerInterrupt: String,
                                   meetingIdentifier: String,
                                   localChange: Bool)
    func callToSpeakerInterrupt(for meetingIdentifier: String) -> ValueTimeStampPair<String>

    func setIAmDoneInterrupt(iAmDoneInterrupt: String,
                             meetingIdentifier: String,
                             localChange: Bool)
    func iAmDoneInterrupt(for meetingIdentifier: String) -> ValueTimeStampPair<String>

    func setMeetingParamsMaxTalkTime(maxTalkTime: Int64,
                                     meetingIdentifier: String,
                                     localChange: Bool)
    func meetingParamsMaxTalkTime(for meetingIdentifier: String) -> ValueTimeStampPair<Int64>

    func setMeetingState(meetingState: String,
                         meetingIdentifier: String,
                         localChange: Bool)
    func meetingState(for meetingIdentifier: String) -> ValueTimeStampPair<String>
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

    // MARK: - Meeting Params: Agenda
    func setMeetingParamsAgenda(agenda: String,
                                meetingIdentifier: String,
                                localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.meetingParamsAgenda = agenda

            if localChange {
                hostPersisted.meetingParamsAgendaChanged =
                    HostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingParamsAgendaChanged = 0
            }

            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func meetingParamsAgenda(for meetingIdentifier: String) -> ValueTimeStampPair<String> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                print("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<String>(value: "", timestamp: 0)
            }
            return ValueTimeStampPair<String>(value: hostPersisted.meetingParamsAgenda ?? "",
                                              timestamp: hostPersisted.meetingParamsAgendaChanged ?? 0)
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }

    // MARK: - Meeting Params: MaxTalkTime
    func setMeetingParamsMaxTalkTime(maxTalkTime: Int64,
                                     meetingIdentifier: String,
                                     localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.meetingParamsMaxTalkTime = maxTalkTime

            if localChange {
                hostPersisted.meetingParamsMaxTalkTimeChanged =
                    HostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingParamsMaxTalkTimeChanged = 0
            }

            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func meetingParamsMaxTalkTime(for meetingIdentifier: String) -> ValueTimeStampPair<Int64> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                print("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<Int64>(value: 0, timestamp: 0)
            }
            return ValueTimeStampPair<Int64>(value: hostPersisted.meetingParamsMaxTalkTime,
                                             timestamp: hostPersisted.meetingParamsMaxTalkTimeChanged ?? 0)
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

    // MARK: - I Am Done Interrupt
    func setIAmDoneInterrupt(iAmDoneInterrupt: String,
                             meetingIdentifier: String,
                             localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.iAmDoneInterrupt = iAmDoneInterrupt

            if localChange {
                hostPersisted.iAmDoneInterruptChanged =
                    HostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.iAmDoneInterruptChanged = 0
            }

            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func iAmDoneInterrupt(for meetingIdentifier: String) -> ValueTimeStampPair<String> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                assertionFailure("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<String>(value: "", timestamp: 0)
            }
            return ValueTimeStampPair<String>(value: hostPersisted.iAmDoneInterrupt ?? "",
                                              timestamp: hostPersisted.iAmDoneInterruptChanged ?? 0)
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }

    // MARK: - Meeting State
    func setMeetingState(meetingState: String,
                         meetingIdentifier: String,
                         localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.meetingState  = meetingState

            if localChange {
                hostPersisted.meetingStateChanged =
                    HostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingStateChanged = 0
            }

            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func meetingState(for meetingIdentifier: String) -> ValueTimeStampPair<String> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                assertionFailure("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<String>(value: "", timestamp: 0)
            }
            return ValueTimeStampPair<String>(value: hostPersisted.meetingState  ?? "",
                                              timestamp: hostPersisted.meetingStateChanged ?? 0)
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }

    // MARK: - Moderator Has Control
    func setModeratorHasControl(hasControl: Bool,
                                meetingIdentifier: String,
                                localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.moderatorHasControl  = hasControl

            if localChange {
                hostPersisted.moderatorHasControlChanged =
                    HostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.moderatorHasControlChanged = 0
            }

            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func moderatorHasControl(for meetingIdentifier: String) -> ValueTimeStampPair<Bool> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                print("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<Bool>(value: false, timestamp: 0)
            }
            return ValueTimeStampPair<Bool>(value: hostPersisted.moderatorHasControl,
                                            timestamp: hostPersisted.moderatorHasControlChanged ?? 0)
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }

    // MARK: - Participants
    func setParticipants(participants: [String],
                         meetingIdentifier: String,
                         localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.participants = participants

            if localChange {
                hostPersisted.participantsChanged =
                    HostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.participantsChanged = 0
            }

            try managedObjectContext.save()
        } catch {
            assertionFailure("Error setting meeting parameters. \(error)")
        }
    }

    func participants(for meetingIdentifier: String) -> ValueTimeStampPair<[String]> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                assertionFailure("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<[String]>(value: [], timestamp: 0)
            }
            return ValueTimeStampPair<[String]>(value: hostPersisted.participants ?? [],
                                                timestamp: hostPersisted.participantsChanged ?? 0)
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
