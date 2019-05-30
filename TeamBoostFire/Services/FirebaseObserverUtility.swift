//
//  FirebaseObserverUtility.swift
//

import Foundation
import Firebase
import FirebaseDatabase

struct FirebaseObserverUtility {
    let firebaseReferenceContainer: FirebaseReferenceContainer
    weak var teamBoostCore: TeamBoostCore?
    
    init(with firebaseReferenceContainer: FirebaseReferenceContainer,
        teamBoostCore: TeamBoostCore) {
        self.firebaseReferenceContainer = firebaseReferenceContainer
        self.teamBoostCore = teamBoostCore
    }

    public func observeSpeakerOrderDidChange() {
        firebaseReferenceContainer.speakerOrderReference?.observe(DataEventType.value, with: { snapshot in
            guard let speakerOrder = snapshot.value as? [String] else {
                return
            }
            self.teamBoostCore?.speakerOrder = speakerOrder
            let name = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: speakerOrder)
        })
    }

    public func observeParticipantListChanges() {
        firebaseReferenceContainer.participantsReference?.observe(DataEventType.value, with: { snapshot in
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

            self.teamBoostCore?.allParticipants = allParticipants
            let name = Notification.Name(TeamBoostNotifications.participantListDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: allParticipants)
        })
    }

    public func observeIAmDoneInterrupt() {
        firebaseReferenceContainer.iAmDoneInterruptReference?.observe(DataEventType.value, with: { snapshot in
            let name = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: nil)
        })
    }

    public func observeMeetingStateDidChange() {
        firebaseReferenceContainer.meetingStateReference?.observe(DataEventType.value, with: { snapshot in
            let meetingState = MeetingState(rawValue: snapshot.value as! String)
            let name = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: meetingState)
        })
    }

    public func observeMeetingParamsDidChange() {
        firebaseReferenceContainer.meetingParamsReference?.observe(DataEventType.value, with: { snapshot in
            guard let agenda = snapshot.childSnapshot(forPath: TableKeys.Agenda.rawValue).value as? String else {
                assertionFailure("Error while retrieving agenda")
                return
            }

            guard let meetingTime = snapshot.childSnapshot(forPath: TableKeys.MeetingTime.rawValue).value as? Int else {
                assertionFailure("Error while retrieving meeting time")
                return
            }

            guard let maxTalkTime = snapshot.childSnapshot(forPath: TableKeys.MaxTalkTime.rawValue).value as? Int else {
                assertionFailure("Error while retrieving max talk time")
                return
            }

            let meetingParams = MeetingsParams(agenda: agenda,
                                                meetingTime: meetingTime,
                                                maxTalkTime: maxTalkTime,
                                                moderationMode: nil)

            self.teamBoostCore?.meetingParams = meetingParams

            let name = Notification.Name(TeamBoostNotifications.meetingParamsDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: meetingParams)
        })
    }
}
