//
//  CoreServices.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class CoreServices {
    static let shared = CoreServices()
    private var databaseRef: DatabaseReference?

    private var meetingReference: DatabaseReference?
    private var meetingStateReference: DatabaseReference?
    private var activeSpeakerReference: DatabaseReference?
    private var participantsReference: DatabaseReference?
    private var meetingParamsReference: DatabaseReference?

    private var meetingParamsTimeReference: DatabaseReference?
    private var meetingParamsMaxTalkingTimeReference: DatabaseReference?
    private var meetingParamsAgendaReference: DatabaseReference?

    public var allParticipants: [Participant]?

    private(set) public var meetingIdentifier: String?
    private(set) public var meetingParams: MeetingsParams?
    private(set) public var selfIdentifier: String?

    private init() {
        print("ALOG: CoreServices: Initialiser called")
        FirebaseApp.configure()
        self.databaseRef = Database.database().reference()
    }


}

// MARK: - Host
extension CoreServices {
    public func setupMeetingAsHost(with params: MeetingsParams) {
        meetingIdentifier = String.makeSixDigitUUID()
        meetingReference = databaseRef?.child(meetingIdentifier!)

        meetingStateReference = meetingReference?.child("meeting_state")
        meetingStateReference?.setValue("suspended")

        activeSpeakerReference = meetingReference?.child("active_speaker")
        activeSpeakerReference?.setValue("")

        activeSpeakerReference = meetingReference?.child("active_speaker")
        activeSpeakerReference?.setValue("")
        participantsReference = meetingReference?.child("participants")
        participantsReference?.setValue("")
        meetingParamsReference = meetingReference?.child("meeting_params")
        meetingParamsReference?.setValue("")

        meetingParamsTimeReference = meetingParamsReference?.child("meeting_time")
        meetingParamsTimeReference?.setValue(params.meetingTime)
        meetingParamsAgendaReference = meetingParamsReference?.child("agenda")
        meetingParamsAgendaReference?.setValue(params.agenda)
        meetingParamsMaxTalkingTimeReference = meetingParamsReference?.child("max_talking_time")
        meetingParamsMaxTalkingTimeReference?.setValue(params.maxTalkTime)

        meetingParams = params
        observeParticipantListChanges()
        observeActiveSpeakerDidChange()
    }

    public func startMeeting() {
        meetingStateReference?.setValue("started")
    }

    public func endMeeting() {
        meetingStateReference?.setValue("ended")
    }

    public func setActiveSpeaker(identifier: String) {
        activeSpeakerReference?.setValue(identifier)
    }

    private func observeParticipantListChanges() {
        participantsReference?.observe(DataEventType.value, with: { snapshot in
            let allObjects = snapshot.children.allObjects as! [DataSnapshot]
            var allParticipants =  [Participant]()
            for object in allObjects {
                let dict = object.value as! [String: String]
                let participantIdentifier = dict["id"]
                let participantName = dict["name"]
                let participant = Participant(id: participantIdentifier!, name: participantName!, isActiveSpeaker: false)
                allParticipants.append(participant)
            }

            let name = Notification.Name(TeamBoostNotifications.participantListDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: allParticipants)

        })
    }

    private func observeActiveSpeakerDidChange() {
        activeSpeakerReference?.observe(DataEventType.value, with: { snapshot in
            let activeSpeakerId = snapshot.value as! String
            let name = Notification.Name(TeamBoostNotifications.activeSpeakerDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: activeSpeakerId)
        })
    }


}

// MARK: - Participant
extension CoreServices {
    public func setupMeetingAsParticipant(participant: Participant, meetingCode: String) {
        meetingIdentifier = meetingCode
        selfIdentifier = participant.id
        meetingReference = databaseRef?.child(meetingIdentifier!)
        meetingStateReference = meetingReference?.child("meeting_state")
        activeSpeakerReference = meetingReference?.child("active_speaker")
        participantsReference = meetingReference?.child("participants")
        meetingParamsReference = meetingReference?.child("meeting_params")
        meetingParamsTimeReference = meetingParamsReference?.child("meeting_time")
        meetingParamsAgendaReference = meetingParamsReference?.child("agenda")
        participantsReference?.child(participant.id).setValue(["name": participant.name,
                                                               "id":participant.id])

        observeMeetingStateDidChange()
    }

    private func observeMeetingStateDidChange() {
        meetingStateReference?.observe(DataEventType.value, with: { snapshot in
            let meetingState = MeetingState(rawValue: snapshot.value as! String)
            let name = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: meetingState)
        })
    }
}

extension String {
    fileprivate static func makeSixDigitUUID() -> String {
        let shortUUID = UUID().uuidString.lowercased()
        return shortUUID.components(separatedBy: "-").first!
    }

}

