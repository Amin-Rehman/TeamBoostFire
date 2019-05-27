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
    private var isHost: Bool

    public private(set) var allParticipants: [Participant]?
    public private(set) var speakerOrder: [String]?
    private(set) public var meetingIdentifier: String?
    private(set) public var meetingParams: MeetingsParams?
    private(set) public var selfParticipantIdentifier: String?

    private var firebaseReferenceContainer: FirebaseReferenceContainer

    private init() {
        print("ALOG: CoreServices: Initialiser called")
        // TODO: Fixme
        self.firebaseReferenceContainer = FirebaseReferenceContainer(with: "foo")
        self.isHost = false
    }

    private func observeSpeakerOrderDidChange() {
        firebaseReferenceContainer.speakerOrderReference?.observe(DataEventType.value, with: { snapshot in
            guard let speakerOrder = snapshot.value as? [String] else {
                return
            }
            self.speakerOrder = speakerOrder
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

}

// MARK: - Host
extension CoreServices {
    public func setupMeetingAsHost(with params: MeetingsParams) {
        isHost = true

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            meetingIdentifier = StubMeetingVars.MeetingCode.rawValue
        } else {
            meetingIdentifier = String.makeSixDigitUUID()
        }

        // TODO: Remove bang!
        firebaseReferenceContainer = FirebaseReferenceContainer(with: meetingIdentifier!)

        firebaseReferenceContainer.meetingStateReference?.setValue("suspended")
        firebaseReferenceContainer.speakerOrderReference?.setValue([""])
        firebaseReferenceContainer.meetingParamsReference?.setValue("")
        firebaseReferenceContainer.iAmDoneInterruptReference?.setValue("")

        firebaseReferenceContainer.meetingParamsTimeReference?.setValue(params.meetingTime)
        firebaseReferenceContainer.meetingParamsAgendaReference?.setValue(params.agenda)
        firebaseReferenceContainer.meetingParamsMaxTalkingTimeReference?.setValue(params.maxTalkTime)

        meetingParams = params
        observeParticipantListChanges()
        observeSpeakerOrderDidChange()
        observeIAmDoneInterrupt()
    }

    public func startMeeting() {
        var allParticipantIdentifiers = [String]()
        guard let allParticipantsGuarded = allParticipants else {
            assertionFailure("No participants found in CoreServices")
            return
        }

        for participant in allParticipantsGuarded {
            allParticipantIdentifiers.append(participant.id)
        }

        updateSpeakerOrder(with: allParticipantIdentifiers)
        firebaseReferenceContainer.meetingStateReference?.setValue("started")
    }

    public func endMeeting() {
        firebaseReferenceContainer.meetingStateReference?.setValue("ended")
    }

    public func updateSpeakerOrder(with identifiers: [String]) {
        assert(isHost, "Only Host can update speaker order")
        speakerOrder = identifiers
        firebaseReferenceContainer.speakerOrderReference?.setValue(speakerOrder)

        var updatedAllParticipants = [Participant]()
        for participant in allParticipants! {
            let participantSpeakingOrder = speakerOrder?.firstIndex(of: participant.id)
            let updatedParticipant = Participant(id: participant.id,
                                                 name: participant.name,
                                                 speakerOrder: participantSpeakingOrder!)
            updatedAllParticipants.append(updatedParticipant)
        }

        allParticipants = updatedAllParticipants
    }

    private func observeIAmDoneInterrupt() {
        firebaseReferenceContainer.iAmDoneInterruptReference?.observe(DataEventType.value, with: { snapshot in
            let name = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: nil)
        })
    }

}

// MARK: - Participant
extension CoreServices {
    public func setupMeetingAsParticipant(participant: Participant, meetingCode: String) {
        isHost = false
        meetingIdentifier = meetingCode
        selfParticipantIdentifier = participant.id
        firebaseReferenceContainer = FirebaseReferenceContainer(with: meetingIdentifier!)
        firebaseReferenceContainer.participantsReference?.child(participant.id).setValue(["name": participant.name,
                                                               "id":participant.id])
        observeParticipantListChanges()
        observeMeetingStateDidChange()
        observeSpeakerOrderDidChange()
        observeMeetingParamsDidChange()
    }

    public func registerParticipantIsDoneInterrupt() {
        let timeStampOfInterrupt = Date().timeIntervalSinceReferenceDate
        firebaseReferenceContainer.iAmDoneInterruptReference?.setValue(timeStampOfInterrupt)
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


            self.meetingParams = MeetingsParams(agenda: agenda,
                                                meetingTime: meetingTime,
                                                maxTalkTime: maxTalkTime,
                                                moderationMode: nil)

            let name = Notification.Name(TeamBoostNotifications.meetingParamsDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: self.meetingParams)
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

