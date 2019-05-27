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
    private var firebaseObserverUtility: FirebaseObserverUtility

    private init() {
        print("ALOG: CoreServices: Initialiser called")
        // TODO: Fixme
        self.firebaseReferenceContainer = FirebaseReferenceContainer(with: "foo")
        self.firebaseObserverUtility = FirebaseObserverUtility(with: self.firebaseReferenceContainer)
        self.isHost = false
    }

}

// MARK: - Host
extension CoreServices {
    public func setupMeetingAsHost(with params: MeetingsParams) {
        isHost = true
        meetingParams = params

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

        firebaseObserverUtility = FirebaseObserverUtility(with: firebaseReferenceContainer)

        firebaseObserverUtility.observeParticipantListChanges()
        firebaseObserverUtility.observeSpeakerOrderDidChange()
        firebaseObserverUtility.observeIAmDoneInterrupt()
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
        firebaseObserverUtility = FirebaseObserverUtility(with: firebaseReferenceContainer)
        firebaseObserverUtility.observeParticipantListChanges()
        firebaseObserverUtility.observeMeetingStateDidChange()
        firebaseObserverUtility.observeSpeakerOrderDidChange()
        firebaseObserverUtility.observeMeetingParamsDidChange()
    }

    public func registerParticipantIsDoneInterrupt() {
        let timeStampOfInterrupt = Date().timeIntervalSinceReferenceDate
        firebaseReferenceContainer.iAmDoneInterruptReference?.setValue(timeStampOfInterrupt)
    }

}

// MARK: - String extension
extension String {
    fileprivate static func makeSixDigitUUID() -> String {
        let shortUUID = UUID().uuidString.lowercased()
        return shortUUID.components(separatedBy: "-").first!
    }

}

