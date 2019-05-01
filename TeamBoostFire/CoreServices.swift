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
    private var speakerOrderReference: DatabaseReference?
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

    private func observeSpeakerOrderDidChange() {
        speakerOrderReference?.observe(DataEventType.value, with: { snapshot in
            let activeSpeakerId = snapshot.value as! String
            let name = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: activeSpeakerId)
        })
    }

}

// MARK: - Host
extension CoreServices {
    public func setupMeetingAsHost(with params: MeetingsParams) {
        meetingIdentifier = String.makeSixDigitUUID()
        meetingReference = databaseRef?.child(meetingIdentifier!)

        meetingStateReference = meetingReference?.referenceOfChild(with: .MeetingState)
        meetingStateReference?.setValue("suspended")

        speakerOrderReference = meetingReference?.referenceOfChild(with: .SpeakerOrder)
        speakerOrderReference?.setValue("")

        participantsReference = meetingReference?.referenceOfChild(with: .Participants)
        participantsReference?.setValue("")
        meetingParamsReference = meetingReference?.referenceOfChild(with: .MeetingParams)
        meetingParamsReference?.setValue("")

        meetingParamsTimeReference = meetingParamsReference?.referenceOfChild(with: .MeetingTime)
        meetingParamsTimeReference?.setValue(params.meetingTime)
        meetingParamsAgendaReference = meetingParamsReference?.referenceOfChild(with: .Agenda)
        meetingParamsAgendaReference?.setValue(params.agenda)
        meetingParamsMaxTalkingTimeReference = meetingParamsReference?.referenceOfChild(with: .MaxTalkTime)
        meetingParamsMaxTalkingTimeReference?.setValue(params.maxTalkTime)

        meetingParams = params
        observeParticipantListChanges()
        observeSpeakerOrderDidChange()
    }

    public func startMeeting() {
        meetingStateReference?.setValue("started")
    }

    public func endMeeting() {
        meetingStateReference?.setValue("ended")
    }

    public func setActiveSpeaker(identifier: String) {
        speakerOrderReference?.setValue(identifier)
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
}

// MARK: - Participant
extension CoreServices {
    public func setupMeetingAsParticipant(participant: Participant, meetingCode: String) {
        meetingIdentifier = meetingCode
        selfIdentifier = participant.id
        meetingReference = databaseRef?.child(meetingIdentifier!)
        meetingStateReference = meetingReference?.referenceOfChild(with: .MeetingState)
        speakerOrderReference = meetingReference?.referenceOfChild(with: .SpeakerOrder)
        participantsReference = meetingReference?.referenceOfChild(with: .Participants)
        participantsReference?.child(participant.id).setValue(["name": participant.name,
                                                               "id":participant.id])
        meetingParamsReference = meetingReference?.referenceOfChild(with: .MeetingParams)
        meetingParamsTimeReference = meetingParamsReference?.referenceOfChild(with: .MeetingTime)
        meetingParamsAgendaReference = meetingParamsReference?.referenceOfChild(with: .Agenda)

        observeMeetingStateDidChange()
        observeSpeakerOrderDidChange()
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


// MARK: - String extension
extension String {
    fileprivate static func makeSixDigitUUID() -> String {
        let shortUUID = UUID().uuidString.lowercased()
        return shortUUID.components(separatedBy: "-").first!
    }

}

extension DatabaseReference {
    func referenceOfChild(with key: TableKeys) -> DatabaseReference {
        return self.child(key.rawValue)
    }
}

