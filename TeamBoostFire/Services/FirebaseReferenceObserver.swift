//
//  FirebaseReferenceObserver.swift
//

import Foundation
import Firebase
import FirebaseDatabase
import TeamBoostKit

struct FirebaseReferenceObserver: ReferenceObserving {
    func observeCallToSpeakerDidChange(subscriber: @escaping (String) -> Void) {
        firebaseReferenceHolder.callToSpeakerReference?.observe(DataEventType.value, with: { snapshot in
            guard let callToSpeakerWithUniqueId = snapshot.value as? String else {
                assertionFailure("Error retrieving call to speaker Id with Unique Id")
                return
            }
            subscriber(callToSpeakerWithUniqueId)
        })
    }


    let firebaseReferenceHolder: FirebaseReferenceHolder

    init(with firebaseReferenceHolder: FirebaseReferenceHolder) {
        self.firebaseReferenceHolder = firebaseReferenceHolder
    }

    public func observeSpeakerOrderDidChange(subscriber: @escaping ([String]) -> Void) {
        firebaseReferenceHolder.speakerOrderReference?.observe(DataEventType.value, with: { snapshot in
            guard let speakerOrder = snapshot.value as? [String] else {
                return
            }
            subscriber(speakerOrder)
        })
    }

    public func observeParticipantListChanges(subscriber: @escaping ([Participant]) -> Void) {
        firebaseReferenceHolder.participantsReference?.observe(DataEventType.value, with: { snapshot in
            let allObjects = snapshot.children.allObjects as! [DataSnapshot]
            var allParticipants =  [Participant]()
            for object in allObjects {
                let dict = object.value as! [String: String]
                let participantIdentifier = dict["id"]
                let participantName = dict["name"]
                let participant = Participant(id: participantIdentifier!,
                                              name: participantName!,
                                              speakerOrder: -1)
                allParticipants.append(participant)
            }
            subscriber(allParticipants)
        })
    }

    public func observeIAmDoneInterrupt(subscriber: @escaping (TimeInterval) -> Void) {
        firebaseReferenceHolder.iAmDoneInterruptReference?.observe(DataEventType.value, with: { snapshot in
            guard let iAmDoneInterruptValue = snapshot.value as? TimeInterval else {
                assertionFailure("Error retrieving I am done interrupt value")
                return
            }
            subscriber(iAmDoneInterruptValue)
        })
    }

    public func observeModeratorHasControlDidChange(subscriber: @escaping (Bool) -> Void) {
        firebaseReferenceHolder.moderatorHasControlReference?.observe(DataEventType.value, with: { snapshot in
            guard let moderatorHasControlState = snapshot.value as? Bool else {
                assertionFailure("Error retrieving meeting state")
                return
            }
            subscriber(moderatorHasControlState)
        })
    }

    public func observeMeetingStateDidChange(subscriber: @escaping (MeetingState) -> Void) {
        firebaseReferenceHolder.meetingStateReference?.observe(DataEventType.value, with: { snapshot in
            guard let meetingState = MeetingState(rawValue: snapshot.value as! String) else {
                assertionFailure("Error retrieving meeting state")
                return
            }
            subscriber(meetingState)
        })
    }

    public func observeMeetingParamsDidChange(subscriber: @escaping (MeetingsParams) -> Void) {
        firebaseReferenceHolder.meetingParamsReference?.observe(DataEventType.value, with: { snapshot in
            guard let agenda = snapshot.childSnapshot(forPath: TableKeys.Agenda.rawValue).value as? String else {
                assertionFailure("Error while retrieving agenda")
                return
            }

            guard let meetingTime = snapshot.childSnapshot(forPath: TableKeys.MeetingTime.rawValue).value as? Int else {
                assertionFailure("Error while retrieving meeting time")
                return
            }

            guard let maxTalkTime = snapshot.childSnapshot(
                forPath: TableKeys.MaxTalkTime.rawValue).value as? Int else {
                assertionFailure("Error while retrieving max talk time")
                return
            }

            let meetingParams = MeetingsParams(agenda: agenda,
                                                meetingTime: meetingTime,
                                                maxTalkTime: maxTalkTime,
                                                moderationMode: nil)

            subscriber(meetingParams)
        })
    }
}
