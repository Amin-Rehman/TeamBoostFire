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
    public func setupMeeting(with params: MeetingsParams) {
        meetingIdentifier = String.makeSixDigitUUID()
        print("ALOG: About to setup meeting with identifier: \(meetingIdentifier!)")
        meetingReference = databaseRef?.child(meetingIdentifier!)

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
    }

    public func subscribeToParticipantChangesList() {
        participantsReference?.observe(DataEventType.value, with: { snapshot in
            if snapshot.hasChildren() {
                let allObjects = snapshot.children.allObjects
                print(allObjects)
            }
        })
    }

}

// MARK: - Participant
extension CoreServices {
    public func addParticipant(participant: Participant, meetingCode: String) {
        meetingIdentifier = meetingCode
        meetingReference = databaseRef?.child(meetingIdentifier!)
        activeSpeakerReference = meetingReference?.child("active_speaker")
        participantsReference = meetingReference?.child("participants")
        meetingParamsReference = meetingReference?.child("meeting_params")
        meetingParamsTimeReference = meetingParamsReference?.child("time")
        meetingParamsAgendaReference = meetingParamsReference?.child("agenda")
        participantsReference?.child(participant.id).setValue(["name": participant.name])
    }
}

extension String {
    fileprivate static func makeSixDigitUUID() -> String {
        let shortUUID = UUID().uuidString.lowercased()
        return shortUUID.components(separatedBy: "-").first!
    }

}

