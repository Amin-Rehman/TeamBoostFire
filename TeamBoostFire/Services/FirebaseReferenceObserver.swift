//
//  FirebaseReferenceObserver.swift
//

import Foundation
import Firebase
import FirebaseDatabase

public protocol ReferenceObserving {
    func observeSpeakerOrderDidChange(subscriber: @escaping ([String]) -> Void)
    func observeParticipantListChanges(subscriber: @escaping ([Participant]) -> Void)
    func observeIAmDoneInterrupt(subscriber: @escaping () -> Void)
    func observeMeetingStateDidChange(subscriber: @escaping (MeetingState) -> Void)
    func observeMeetingParamsDidChange(subscriber: @escaping (MeetingsParams) -> Void)


}

struct FirebaseReferenceObserver: ReferenceObserving {

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

    public func observeIAmDoneInterrupt(subscriber: @escaping () -> Void) {
        firebaseReferenceHolder.iAmDoneInterruptReference?.observe(DataEventType.value, with: { snapshot in
            subscriber()
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
