//
//  FirebaseHostPusher.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.03.20.
//  Copyright © 2020 Amin Rehman. All rights reserved.
//

import Foundation

/**
 Observes changes in the storage and pushes out the changes to firebase if there are local changes.
 Local changes are determined if there is a time stamp.
 */
class FirebaseHostPusher: StorageChangeObserving {
    var storage: PersistenceStorage
    let firebaseReferenceHolder: ReferenceHolding
    let meetingIdentifier: String

    init(with storage: PersistenceStorage,
         firebaseReferenceHolder: ReferenceHolding,
         meetingIdentifier: String) {
        self.storage = storage
        self.firebaseReferenceHolder = firebaseReferenceHolder
        self.meetingIdentifier = meetingIdentifier
        self.storage.storageChangedObserver = self
    }

    func storageDidChange() {
        pushSpeakerOrderIfNeeded()
        pushModeratorHasControlIfNeeded()
        pushMeetingStateIfNeeded()
    }

    private func pushSpeakerOrderIfNeeded() {
        let speakerOrderValuePair = storage.speakerOrder(for: meetingIdentifier)
        if speakerOrderValuePair.hasTimeStamp() {
            firebaseReferenceHolder.setReferenceForSpeakerOrder(speakingOrder: speakerOrderValuePair.value)
        }
    }

    private func pushModeratorHasControlIfNeeded() {
        let moderatorHasControlValuePair = storage.moderatorHasControl(for: meetingIdentifier)
        if moderatorHasControlValuePair.hasTimeStamp() {
            firebaseReferenceHolder.setReferenceForModeratorHasControl(
                controlState: moderatorHasControlValuePair.value)
        }
    }

    private func pushMeetingStateIfNeeded() {
        let meetingStateValuePair = storage.meetingState(for: meetingIdentifier)
        if meetingStateValuePair.hasTimeStamp() {
            switch meetingStateValuePair.value {
            // TODO: Replace with enum
            case "started":
                firebaseReferenceHolder.setReferenceForMeetingStarted()
            case "ended":
                firebaseReferenceHolder.setReferenceForMeetingEnded()
            default:
                firebaseReferenceHolder.setReferenceForMeetingEnded()
            }
        }
    }
}
