//
//  HostDomain.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

struct HostDomain {
    let pusher: FirebaseHostPusher
    let fetcher: FirebaseHostFetcher
    let storage: PersistenceStorage
    let meetingIdentifier: String

    var speakerOrder: [String] {
        get {
            return self.storage.speakerOrder(for: self.meetingIdentifier).value
        }
    }

    var allParticipants: [Participant] {
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
         meetingIdentifier: String) {
        self.pusher = pusher
        self.fetcher = fetcher
        self.storage = storage
        self.meetingIdentifier = meetingIdentifier
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
