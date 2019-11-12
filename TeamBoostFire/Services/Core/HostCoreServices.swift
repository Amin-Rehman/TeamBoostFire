//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class HostCoreServices: TeamBoostCore {
    var speakerOrder: [String]?
    var allParticipants: [Participant]?
    var meetingParams: MeetingsParams?

    var meetingStatistics: MeetingStats?

    static let shared = HostCoreServices()

    private(set) public var meetingIdentifier: String?
    private var firebaseReferenceContainer: FirebaseReferenceContainer?
    private var firebaseObserverUtility: FirebaseObserverUtility?

    private init() {}

    public func setupCore(with params: MeetingsParams) {
        meetingParams = params

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            meetingIdentifier = StubMeetingVars.MeetingCode.rawValue

        } else {
            meetingIdentifier = String.makeSixDigitRandomNumbers()
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
        firebaseObserverUtility = FirebaseObserverUtility(with: guardedFirebaseReferenceContainer,
                                                          teamBoostCore: self)

        firebaseReferenceContainer?.meetingStateReference?.setValue("suspended")
        firebaseReferenceContainer?.speakerOrderReference?.setValue([""])
        firebaseReferenceContainer?.meetingParamsReference?.setValue("")
        firebaseReferenceContainer?.iAmDoneInterruptReference?.setValue("")
        firebaseReferenceContainer?.currentSpeakerMaximumSpeakingTime?.setValue(0)
        firebaseReferenceContainer?.meetingParamsTimeReference?.setValue(params.meetingTime)
        firebaseReferenceContainer?.meetingParamsAgendaReference?.setValue(params.agenda)
        firebaseReferenceContainer?.meetingParamsMaxTalkingTimeReference?.setValue(params.maxTalkTime)
        firebaseReferenceContainer?.callToSpeakerQueueReference?.setValue([""])

        firebaseObserverUtility?.observeParticipantListChanges()
        firebaseObserverUtility?.observeSpeakerOrderDidChange()
        firebaseObserverUtility?.observeIAmDoneInterrupt()

        injectFakeParticipantsForTestModeIfNeeded()
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


extension HostCoreServices {
    public func injectFakeParticipantsForTestModeIfNeeded() {
        self.firebaseReferenceContainer?.participantsReference?.setValue(nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.testEnvironment == true {
                let participantOneId = UUID().uuidString
                self.firebaseReferenceContainer?.participantsReference?
                    .child(participantOneId).setValue(["name": "Jon Snow",
                                                       "id": participantOneId])

                let participantTwoId = UUID().uuidString
                self.firebaseReferenceContainer?.participantsReference?
                    .child(participantTwoId).setValue(["name": "Ned Stark",
                                                       "id": participantTwoId])

                let participantThreeId = UUID().uuidString
                self.firebaseReferenceContainer?.participantsReference?
                    .child(participantThreeId).setValue(["name": "Cersei Lannister",
                                                         "id": participantThreeId])
            }
        }
    }
}

// MARK: - String extension
extension String {
    fileprivate static func makeSixDigitUUID() -> String {
        let shortUUID = UUID().uuidString.lowercased()
        return shortUUID.components(separatedBy: "-").first!
    }

    fileprivate static func makeSixDigitRandomNumbers() -> String {
        let number1 = Int.random(in: 0 ..< 10)
        let number2 = Int.random(in: 0 ..< 10)
        let number3 = Int.random(in: 0 ..< 10)
        let number4 = Int.random(in: 0 ..< 10)
        let number5 = Int.random(in: 0 ..< 10)
        let number6 = Int.random(in: 0 ..< 10)
        return String("\(number1)\(number2)\(number3)-\(number4)\(number5)\(number6)")
    }
}

