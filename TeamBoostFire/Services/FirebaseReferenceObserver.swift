//
//  FirebaseReferenceObserver.swift
//

import Foundation
import Firebase
import FirebaseDatabase

public protocol ReferenceObserving {
    func observeSpeakerOrderDidChange()
    func observeParticipantListChanges()
    func observeIAmDoneInterrupt()
    func observeMeetingStateDidChange()
    func observeMeetingParamsDidChange()

    func handleSpeakerOrderDidChange(speakerOrder: [String])
    func handleParticipantListDidChange(participantList: [Participant])
    func handleIAmDoneInterrupt()
    func handleMeetingStateDidChange(meetingState: MeetingState)
    func handleMeetingParamsDidChange(meetingParams: MeetingsParams)


    mutating func setObserver(teamBoostCore: TeamBoostCore)
}

struct FirebaseReferenceObserver: ReferenceObserving {
    func handleMeetingParamsDidChange(meetingParams: MeetingsParams) {
        self.teamBoostCore?.meetingParams = meetingParams

        let name = Notification.Name(TeamBoostNotifications.meetingParamsDidChange.rawValue)
        NotificationCenter.default.post(name: name,
                                        object: meetingParams)
    }
    

    func handleSpeakerOrderDidChange(speakerOrder: [String]) {
        self.teamBoostCore?.speakerOrder = speakerOrder
        let name = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
        NotificationCenter.default.post(name: name,
                                        object: speakerOrder)
    }

    func handleParticipantListDidChange(participantList: [Participant]) {
        self.teamBoostCore?.allParticipants = participantList
        let name = Notification.Name(TeamBoostNotifications.participantListDidChange.rawValue)
        NotificationCenter.default.post(name: name,
                                        object: participantList)
    }

    func handleIAmDoneInterrupt() {
        let name = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
        NotificationCenter.default.post(name: name,
                                        object: nil)
    }

    func handleMeetingStateDidChange(meetingState: MeetingState) {
        let name = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
        NotificationCenter.default.post(name: name,
                                        object: meetingState)
    }

    let firebaseReferenceHolder: FirebaseReferenceHolder
    weak var teamBoostCore: TeamBoostCore?
    
    init(with firebaseReferenceHolder: FirebaseReferenceHolder) {
        self.firebaseReferenceHolder = firebaseReferenceHolder
    }

    public mutating func setObserver(teamBoostCore: TeamBoostCore) {
        self.teamBoostCore = teamBoostCore
    }

    public func observeSpeakerOrderDidChange() {
        firebaseReferenceHolder.speakerOrderReference?.observe(DataEventType.value, with: { snapshot in
            guard let speakerOrder = snapshot.value as? [String] else {
                return
            }
            self.handleSpeakerOrderDidChange(speakerOrder: speakerOrder)
        })
    }

    public func observeParticipantListChanges() {
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

            self.handleParticipantListDidChange(participantList: allParticipants)

        })
    }

    public func observeIAmDoneInterrupt() {
        firebaseReferenceHolder.iAmDoneInterruptReference?.observe(DataEventType.value, with: { snapshot in
            self.handleIAmDoneInterrupt()
        })
    }

    public func observeMeetingStateDidChange() {
        firebaseReferenceHolder.meetingStateReference?.observe(DataEventType.value, with: { snapshot in
            guard let meetingState = MeetingState(rawValue: snapshot.value as! String) else {
                assertionFailure("Error retrieving meeting state")
                return
            }
            self.handleMeetingStateDidChange(meetingState: meetingState)
        })
    }

    public func observeMeetingParamsDidChange() {
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
            self.handleMeetingParamsDidChange(meetingParams: meetingParams)
        })
    }
}
