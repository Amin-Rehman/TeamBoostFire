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
    private var meetingParamsAgendaReference: DatabaseReference?


    private(set) public var meetingIdentifier: String?

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
        meetingReference?.setValue("suspended")

        activeSpeakerReference = meetingReference?.child("active_speaker")
        activeSpeakerReference?.setValue("")

        activeSpeakerReference = meetingReference?.child("active_speaker")
        activeSpeakerReference?.setValue("")
        participantsReference = meetingReference?.child("participants")
        participantsReference?.setValue("")
        meetingParamsReference = meetingReference?.child("meeting_params")
        meetingParamsReference?.setValue("")

        meetingParamsTimeReference = meetingParamsReference?.child("time")
        meetingParamsTimeReference?.setValue(params.meetingTime)
        meetingParamsAgendaReference = meetingParamsReference?.child("agenda")
        meetingParamsAgendaReference?.setValue(params.agenda)

        subscribeToParticipantChangesList()
    }

    public func startMeeting() {
        meetingReference?.setValue("started")
    }

    public func endMeeting() {
        meetingReference?.setValue("ended")
    }

    private func subscribeToParticipantChangesList() {
        participantsReference?.observe(DataEventType.value, with: { snapshot in
            let allObjects = snapshot.children.allObjects as! [DataSnapshot]
            var allParticipants =  [Participant]()
            for object in allObjects {
                let dict = object.value as! [String: String]
                let participantIdentifier = dict["id"]
                let participantName = dict["name"]
                let participant = Participant(id: participantIdentifier!, name: participantName!)
                allParticipants.append(participant)
            }

            let name = Notification.Name(TeamBoostNotifications.participantListDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: allParticipants)

        })
    }

}

// MARK: - Participant
extension CoreServices {
    public func setupMeetingAsParticipant(participant: Participant, meetingCode: String) {
        meetingIdentifier = meetingCode
        meetingReference = databaseRef?.child(meetingIdentifier!)
        meetingStateReference = meetingReference?.child("meeting_state")
        activeSpeakerReference = meetingReference?.child("active_speaker")
        participantsReference = meetingReference?.child("participants")
        meetingParamsReference = meetingReference?.child("meeting_params")
        meetingParamsTimeReference = meetingParamsReference?.child("time")
        meetingParamsAgendaReference = meetingParamsReference?.child("agenda")
        participantsReference?.child(participant.id).setValue(["name": participant.name,
                                                               "id":participant.id])

        observeMeetingStateDidChange()
    }

    private func observeMeetingStateDidChange() {
        meetingStateReference?.observe(DataEventType.value, with: { snapshot in
            let object = snapshot.children.allObjects as! [DataSnapshot]

            let name = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: nil)

        })
    }
}

extension String {
    fileprivate static func makeSixDigitUUID() -> String {
        let shortUUID = UUID().uuidString.lowercased()
        return shortUUID.components(separatedBy: "-").first!
    }

}

