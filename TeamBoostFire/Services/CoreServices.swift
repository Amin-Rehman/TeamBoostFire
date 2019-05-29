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

class HostCoreServices {
    static let shared = HostCoreServices()
    public var speakerOrder: [String]?

    public private(set) var allParticipants: [Participant]?
    private(set) public var meetingIdentifier: String?
    private(set) public var meetingParams: MeetingsParams?
    private(set) public var selfParticipantIdentifier: String?

    private var firebaseReferenceContainer: FirebaseReferenceContainer?
    private var firebaseObserverUtility: FirebaseObserverUtility?

    private init() {
        print("ALOG: HostCoreServices: Initialiser called")
    }

    public func setupCore(with params: MeetingsParams) {
        meetingParams = params

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            meetingIdentifier = StubMeetingVars.MeetingCode.rawValue
        } else {
            meetingIdentifier = String.makeSixDigitUUID()
        }

        guard let meetingId = meetingIdentifier else {
            assertionFailure("Unable to retrieve meeting identifier")
            return
        }
        firebaseReferenceContainer = FirebaseReferenceContainer(with: meetingId)

        guard let guardedFirebaseReferenceContainer = firebaseReferenceContainer else {
            assertionFailure("guardedFirebaseReferenceContainer not properly setup")
            return
        }
        firebaseObserverUtility = FirebaseObserverUtility(with: guardedFirebaseReferenceContainer)

        firebaseReferenceContainer?.meetingStateReference?.setValue("suspended")
        firebaseReferenceContainer?.speakerOrderReference?.setValue([""])
        firebaseReferenceContainer?.meetingParamsReference?.setValue("")
        firebaseReferenceContainer?.iAmDoneInterruptReference?.setValue("")
        firebaseReferenceContainer?.meetingParamsTimeReference?.setValue(params.meetingTime)
        firebaseReferenceContainer?.meetingParamsAgendaReference?.setValue(params.agenda)
        firebaseReferenceContainer?.meetingParamsMaxTalkingTimeReference?.setValue(params.maxTalkTime)
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
        firebaseReferenceContainer?.meetingStateReference?.setValue("started")
    }

    public func endMeeting() {
        firebaseReferenceContainer?.meetingStateReference?.setValue("ended")
    }

    public func updateSpeakerOrder(with identifiers: [String]) {
        speakerOrder = identifiers
        firebaseReferenceContainer?.speakerOrderReference?.setValue(speakerOrder)

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


class ParticipantCoreServices {
    static let shared = ParticipantCoreServices()

    public private(set) var allParticipants: [Participant]?
    public private(set) var speakerOrder: [String]?
    private(set) public var meetingIdentifier: String?
    private(set) public var meetingParams: MeetingsParams?
    private(set) public var selfParticipantIdentifier: String?

    private var firebaseReferenceContainer: FirebaseReferenceContainer?
    private var firebaseObserverUtility: FirebaseObserverUtility?

    private init() {}

    public func setupCore(with participant: Participant,
                          meetingCode: String) {
        print("ALOG: ParticipantCoreServices: setupCore called")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            self.meetingIdentifier = StubMeetingVars.MeetingCode.rawValue
        } else {
            self.meetingIdentifier = meetingCode
        }
        self.firebaseReferenceContainer = FirebaseReferenceContainer(with: meetingIdentifier!)
        firebaseReferenceContainer?.participantsReference?.child(participant.id).setValue(["name": participant.name,
                                                                                          "id":participant.id])

        guard let firebaseReferenceContainer = self.firebaseReferenceContainer else {
            assertionFailure("fireBaseReferenceContainer unable to be initialised")
            return
        }
        self.firebaseObserverUtility = FirebaseObserverUtility(with: firebaseReferenceContainer)
    }

    public func registerParticipantIsDoneInterrupt() {
        let timeStampOfInterrupt = Date().timeIntervalSinceReferenceDate
        firebaseReferenceContainer?.iAmDoneInterruptReference?.setValue(timeStampOfInterrupt)
    }
}

// MARK: - String extension
extension String {
    fileprivate static func makeSixDigitUUID() -> String {
        let shortUUID = UUID().uuidString.lowercased()
        return shortUUID.components(separatedBy: "-").first!
    }

}

