//
//  FirebaseHostFetcher.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

struct FirebaseHostFetcher {
    let storage: HostPersistenceStorage
    let firebaseReferenceObserver: ReferenceObserving
    let meetingIdentifier: String

    init(with storage: HostPersistenceStorage,
         firebaseReferenceObserver: ReferenceObserving,
         meetingIdentifier: String) {
        self.storage = storage
        self.firebaseReferenceObserver = firebaseReferenceObserver
        self.meetingIdentifier = meetingIdentifier
    }
}

// MARK: - Private
extension FirebaseHostFetcher {
    private func setupObservers() {
        firebaseReferenceObserver.observeParticipantListChanges(subscriber: { allParticipants in
            // TODO: Amin - Implement storage interfaces
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

        firebaseReferenceObserver.observeIAmDoneInterrupt(subscriber: {
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
