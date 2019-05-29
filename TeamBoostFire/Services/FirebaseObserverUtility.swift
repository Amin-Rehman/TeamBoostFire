//
//  FirebaseObserverUtility.swift
//

import Foundation
import Firebase
import FirebaseDatabase

struct FirebaseObserverUtility {
    let firebaseReferenceContainer: FirebaseReferenceContainer
    
    init(with firebaseReferenceContainer: FirebaseReferenceContainer) {
        self.firebaseReferenceContainer = firebaseReferenceContainer
        self.observeSpeakerOrderDidChange()
        self.observeParticipantListChanges()
        self.observeIAmDoneInterrupt()
        self.observeMeetingStateDidChange()
        self.observeMeetingParamsDidChange()
    }

    private func observeSpeakerOrderDidChange() {
        firebaseReferenceContainer.speakerOrderReference?.observe(DataEventType.value, with: { snapshot in
            guard let speakerOrder = snapshot.value as? [String] else {
                return
            }
            HostCoreServices.shared.speakerOrder = speakerOrder
            let name = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: speakerOrder)
        })
    }

    private func observeParticipantListChanges() {
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

            self.allParticipants = allParticipants
            let name = Notification.Name(TeamBoostNotifications.participantListDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: allParticipants)
        })
    }

    private func observeIAmDoneInterrupt() {
        firebaseReferenceContainer.iAmDoneInterruptReference?.observe(DataEventType.value, with: { snapshot in
            let name = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: nil)
        })
    }

    private func observeMeetingStateDidChange() {
        firebaseReferenceContainer.meetingStateReference?.observe(DataEventType.value, with: { snapshot in
            let meetingState = MeetingState(rawValue: snapshot.value as! String)
            let name = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: meetingState)
        })
    }

    private func observeMeetingParamsDidChange() {
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

            self.meetingParams = meetingParams

            let name = Notification.Name(TeamBoostNotifications.meetingParamsDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: meetingParams)
        })
    }

}
