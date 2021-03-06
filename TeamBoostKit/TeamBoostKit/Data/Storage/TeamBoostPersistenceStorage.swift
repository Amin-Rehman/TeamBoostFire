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

    func hasTimeStamp() -> Bool {
        return timestamp.doubleValue > 0
    }
}

protocol PersistenceStorage {
    var storageChangedObserver: StorageChangeObserving? { get set }
    var managedObjectContext: NSManagedObjectContext { get }

    func fetchAll() -> [TeamBoostPersisted]
    func setMeeting(with meetingIdentifier: String)
    func clearIfNeeded(meetingIdentifer: String)
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
    func setIAmDoneInterrupt(iAmDoneInterrupt: TimeInterval,
                             meetingIdentifier: String,
                             localChange: Bool)
    func iAmDoneInterrupt(for meetingIdentifier: String) -> ValueTimeStampPair<TimeInterval>
    func setMeetingParamsMaxTalkTime(maxTalkTime: Int64,
                                     meetingIdentifier: String,
                                     localChange: Bool)
    func meetingParamsMaxTalkTime(for meetingIdentifier: String) -> ValueTimeStampPair<Int64>
    func setMeetingState(meetingState: String,
                         meetingIdentifier: String,
                         localChange: Bool)
    func meetingState(for meetingIdentifier: String) -> ValueTimeStampPair<String>
    func setModeratorHasControl(hasControl: Bool,
                                meetingIdentifier: String,
                                localChange: Bool)
    func moderatorHasControl(for meetingIdentifier: String) -> ValueTimeStampPair<Bool>
    func setParticipants(participants: [ParticipantPersisted],
                         meetingIdentifier: String,
                         localChange: Bool)
    func participants(for meetingIdentifier: String) -> ValueTimeStampPair<[ParticipantPersisted]>
    func setSpeakerOrder(speakerOrder: [String],
                         meetingIdentifier: String,
                         localChange: Bool)
    func speakerOrder(for meetingIdentifier: String) -> ValueTimeStampPair<[String]>
}

struct TeamBoostPersistenceStorage: PersistenceStorage {
    weak var storageChangedObserver: StorageChangeObserving?
    let managedObjectContext: NSManagedObjectContext

    func fetchAll() -> [TeamBoostPersisted] {
        do {
            let fetchRequest = NSFetchRequest<TeamBoostPersisted>(entityName: TeamBoostPersisted.entityName)
            return try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalError("Error fetching all hosts")
        }
    }


    /**
     clearIfNeeded should cleanup the entry of the previous meeting to avoid duplicates
     This is a fail safe for the test mode.
     */
    func clearIfNeeded(meetingIdentifer: String)  {
        guard let teamBoostPersisted = try? self.fetchHostPersisted(with: meetingIdentifer) else {
            return
        }

        managedObjectContext.delete(teamBoostPersisted)
        do {
            try managedObjectContext.save()
        } catch {
            assertionFailure("Error when trying to save a deleted change \(error as Any)")
        }
    }

    /**
     setMeeting should always create a new entry in the database and firebase sync
     should only be called once during a meeting
     */
    func setMeeting(with meetingIdentifier: String) {
        let hostPersisted = NSEntityDescription.insertNewObject(
            forEntityName: "TeamBoostPersisted",
            into: managedObjectContext) as! TeamBoostPersisted

        hostPersisted.meetingIdentifier = meetingIdentifier
        hostPersisted.meetingIdentifierChanged = TeamBoostPersistenceStorage.makeCurrentTimestamp()

        managedObjectContext.insert(hostPersisted)
        do {
            try saveAndNotifyObserver()
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
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingParamsMeetingTimeChanged = 0
            }

            try saveAndNotifyObserver()
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
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingParamsAgendaChanged = 0
            }

            try saveAndNotifyObserver()
        } catch {
            assertionFailure("Error setting meeting agenda. \(error)")
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
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingParamsMaxTalkTimeChanged = 0
            }

            try saveAndNotifyObserver()
        } catch {
            assertionFailure("Error setting meeting parameters: Max talk time. \(error)")
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
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingParamsMeetingTimeChanged = 0
            }

            try saveAndNotifyObserver()
        } catch {
            assertionFailure("Error setting meeting parameters - Call to speaker interrupt. \(error)")
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
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.currentSpeakerSpeakingTimeChanged = 0
            }

            try saveAndNotifyObserver()
        } catch {
            assertionFailure("Error setting meeting parameters. - Current speaker speaking time:  \(error)")
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
    func setIAmDoneInterrupt(iAmDoneInterrupt: TimeInterval,
                             meetingIdentifier: String,
                             localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.iAmDoneInterrupt = NSNumber(value: iAmDoneInterrupt)

            if localChange {
                hostPersisted.iAmDoneInterruptChanged =
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.iAmDoneInterruptChanged = 0
            }

            try saveAndNotifyObserver()
        } catch {
            assertionFailure("Error setting meeting parameters - I am Done Interrupt -  \(error)")
        }
    }

    func iAmDoneInterrupt(for meetingIdentifier: String) -> ValueTimeStampPair<TimeInterval> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                assertionFailure("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<TimeInterval>(value: 0.0, timestamp: 0)
            }
            return ValueTimeStampPair<TimeInterval>(value: hostPersisted.iAmDoneInterrupt?.doubleValue ?? 0.0,
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
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.meetingStateChanged = 0
            }

            try saveAndNotifyObserver()
        } catch {
            assertionFailure("Error setting meeting state. \(error)")
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
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.moderatorHasControlChanged = 0
            }

            try saveAndNotifyObserver()
        } catch {
            assertionFailure("Error setting moderator has control. \(error)")
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
    func setParticipants(participants: [ParticipantPersisted],
                         meetingIdentifier: String,
                         localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.participants = participants

            if localChange {
                hostPersisted.participantsChanged =
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.participantsChanged = 0
            }

            try saveAndNotifyObserver()
        } catch {
            assertionFailure("Error setting Participants. \(error)")
        }
    }

    func participants(for meetingIdentifier: String) -> ValueTimeStampPair<[ParticipantPersisted]> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                assertionFailure("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<[ParticipantPersisted]>(value: [], timestamp: 0)
            }
            return ValueTimeStampPair<[ParticipantPersisted]>(value: hostPersisted.participants ?? [],
                                                              timestamp: hostPersisted.participantsChanged ?? 0)
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }

    // MARK: - Speaker Order
    func setSpeakerOrder(speakerOrder: [String],
                         meetingIdentifier: String,
                         localChange: Bool) {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                fatalError("Unable to find persisted object with the identifier")
            }
            hostPersisted.speakerOrder = speakerOrder

            if localChange {
                hostPersisted.speakerOrderChanged  =
                    TeamBoostPersistenceStorage.makeCurrentTimestamp()
            } else {
                hostPersisted.speakerOrderChanged = 0
            }

            try saveAndNotifyObserver()
        } catch {
            assertionFailure("Error setting Speaker Order. \(error)")
        }
    }

    func speakerOrder(for meetingIdentifier: String) -> ValueTimeStampPair<[String]> {
        do {
            guard let hostPersisted  = try fetchHostPersisted(with: meetingIdentifier) else {
                assertionFailure("Persisted object with meeting identifier not found")
                return ValueTimeStampPair<[String]>(value: [], timestamp: 0)
            }
            return ValueTimeStampPair<[String]>(value: hostPersisted.speakerOrder ?? [],
                                                timestamp: hostPersisted.speakerOrderChanged ?? 0)
        } catch {
            fatalError("Error retrieving meeting time: \(error)")
        }
    }
}

extension TeamBoostPersistenceStorage {

    static private func makeCurrentTimestamp() -> NSNumber {
        return NSNumber(value: Date().timeIntervalSinceReferenceDate)
    }

    private func saveAndNotifyObserver() throws {
        try managedObjectContext.save()
        storageChangedObserver?.storageDidChange()
    }

    private func fetchHostPersisted(with meetingIdentifier: String) throws -> TeamBoostPersisted? {
        let fetchRequest = NSFetchRequest<TeamBoostPersisted>(entityName: TeamBoostPersisted.entityName)
        fetchRequest.predicate = NSPredicate(format: "meetingIdentifier == %@", meetingIdentifier)
        let fetchResults = try managedObjectContext.fetch(fetchRequest)
        return fetchResults.first
    }
}
