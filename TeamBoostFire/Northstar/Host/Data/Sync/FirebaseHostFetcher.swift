//
//  FirebaseHostFetcher.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

class FirebaseHostFetcher {
    let storage: PersistenceStorage
    let meetingIdentifier: String
    let firebaseReferenceObserver: ReferenceObserving

    init(with storage: PersistenceStorage,
         meetingIdentifier: String,
         firebaseReferenceObserver: ReferenceObserving) {
        self.storage = storage
        self.meetingIdentifier = meetingIdentifier
        self.firebaseReferenceObserver = firebaseReferenceObserver

        subscribeToReferenceChanges()
    }

    private func subscribeToReferenceChanges() {
        // TODO: Remove TeamBoostNotifications and avoid leakage.
        firebaseReferenceObserver.observeParticipantListChanges(subscriber: { allParticipants in
            let participantPersisted = allParticipants.map { (participant) -> ParticipantPersisted in
                return ParticipantPersisted(id: participant.id, name: participant.name)
            }
            self.storage.setParticipants(participants: participantPersisted,
                                         meetingIdentifier: self.meetingIdentifier,
                                         localChange: false)

            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.participantListDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: allParticipants)
            }
        })
        firebaseReferenceObserver.observeSpeakerOrderDidChange(subscriber: { speakerOrder in
            self.storage.setSpeakerOrder(speakerOrder: speakerOrder,
                                         meetingIdentifier: self.meetingIdentifier,
                                         localChange: false)

            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: speakerOrder)
            }
        })

        firebaseReferenceObserver.observeIAmDoneInterrupt(subscriber: { iAmDoneInterrupt in
            self.storage.setIAmDoneInterrupt(iAmDoneInterrupt: iAmDoneInterrupt,
                                             meetingIdentifier: self.meetingIdentifier,
                                             localChange: false)
            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: nil)
            }
        })

        firebaseReferenceObserver.observeCallToSpeakerDidChange(subscriber: { callToSpeakerId in
            self.storage.setCallToSpeakerInterrupt(callToSpeakerInterrupt: callToSpeakerId,
                                                   meetingIdentifier: self.meetingIdentifier,
                                                   localChange: false)
            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.callToSpeakerDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: callToSpeakerId)
            }
        })
    }
}
