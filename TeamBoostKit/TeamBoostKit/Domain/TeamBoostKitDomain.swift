//
//  HostDomain.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

public class TeamBoostKitDomain {
    let pusher: FirebaseHostPusher
    let fetcher: FirebaseHostFetcher
    let storage: PersistenceStorage
    public let meetingIdentifier: String
    public let meetingParams: MeetingsParams
    public var meetingStatistics: MeetingStats?


    public var speakerOrder: [String] {
        get {
            return self.storage.speakerOrder(for: self.meetingIdentifier).value
        }
    }

    public var allParticipants: [Participant] {
        get {
            let allPersistedParticipants = self.storage.participants(for: self.meetingIdentifier).value

            let participants = allPersistedParticipants.map { participantPersisted -> Participant in
                return Participant(id: participantPersisted.id,
                                   name: participantPersisted.name,
                                   speakerOrder: -1)
            }
            return participants
        }
    }


    init(pusher: FirebaseHostPusher,
         fetcher: FirebaseHostFetcher,
         storage: PersistenceStorage,
         meetingIdentifier: String,
         meetingParams: MeetingsParams) {
        self.pusher = pusher
        self.fetcher = fetcher
        self.storage = storage
        self.meetingIdentifier = meetingIdentifier
        self.meetingParams = meetingParams

        self.storage.clearIfNeeded(meetingIdentifer: meetingIdentifier)
        self.storage.setMeeting(with: meetingIdentifier)
    }

    public func startMeeting() {
        // Get participants from storage
        let allParticipantsPersisted = storage.participants(for: meetingIdentifier)

        let participantIdentifiers = allParticipantsPersisted.value.map { (participantPersisted) -> String in
            return participantPersisted.id
        }

        storage.setSpeakerOrder(speakerOrder: participantIdentifiers,
                                meetingIdentifier: meetingIdentifier,
                                localChange: true)
        // TODO: replace with enum
        storage.setMeetingState(meetingState: "started",
                                meetingIdentifier: meetingIdentifier,
                                localChange: true)
    }

    public func endMeeting() {
        // TODO: replace with enum
        storage.setMeetingState(meetingState: "ended",
                                meetingIdentifier: meetingIdentifier,
                                localChange: true)
    }

    public func updateSpeakerOrder(with identifiers: [String]) {
        storage.setSpeakerOrder(speakerOrder: identifiers,
                                meetingIdentifier: meetingIdentifier,
                                localChange: true)

    }

    public func setModeratorControlState(controlState: Bool) {
        storage.setModeratorHasControl(hasControl: controlState,
                                       meetingIdentifier: self.meetingIdentifier,
                                       localChange: true)
    }

}

extension TeamBoostKitDomain {
    public static func make(referenceObserver: ReferenceObserving,
                            referenceHolder: ReferenceHolding,
                            meetingIdentifier: String,
                            meetingParams: MeetingsParams) -> TeamBoostKitDomain {

        var storage = TeamBoostPersistenceStorage(
            storageChangedObserver: nil,
            managedObjectContext: ManagedObjectContextFactory.make(storageType: .onDisk))

        let fetcher = FirebaseHostFetcher(with: storage,
                                          meetingIdentifier: meetingIdentifier,
                                          firebaseReferenceObserver: referenceObserver)

        let pusher = FirebaseHostPusher(with: storage,
                                        firebaseReferenceHolder: referenceHolder,
                                        meetingIdentifier: meetingIdentifier)
        storage.storageChangedObserver = pusher

        return TeamBoostKitDomain(pusher: pusher,
                          fetcher: fetcher,
                          storage: storage,
                          meetingIdentifier: meetingIdentifier,
                          meetingParams: meetingParams)

    }
}
