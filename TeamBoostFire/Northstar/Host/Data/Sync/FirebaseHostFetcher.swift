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
    let firebaseReferenceObserver: ReferenceObserving

    init(with storage: PersistenceStorage,
         firebaseReferenceObserver: ReferenceObserving) {
        self.storage = storage
        self.firebaseReferenceObserver = firebaseReferenceObserver
    }

    private func subscribeToReferenceChanges() {
        // TODO: Remove TeamBoostNotifications and avoid leakage.
        firebaseReferenceObserver.observeParticipantListChanges(subscriber: { allParticipants in

            // TODO: Save in storage

            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.participantListDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: allParticipants)
            }
        })
        firebaseReferenceObserver.observeSpeakerOrderDidChange(subscriber: { speakerOrder in
            // TODO: Save in storage

            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: speakerOrder)
            }
        })

        firebaseReferenceObserver.observeIAmDoneInterrupt(subscriber: {
            // TODO: Save in storage
            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: nil)
            }
        })

        firebaseReferenceObserver.observeCallToSpeakerDidChange(subscriber: { callToSpeakerId in
            // TODO: Save in storage
            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.callToSpeakerDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: callToSpeakerId)
            }
        })
    }
}
