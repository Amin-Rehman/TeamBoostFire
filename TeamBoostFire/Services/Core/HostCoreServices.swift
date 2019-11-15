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
    private(set) public var meetingIdentifier: String?

    static let shared = HostCoreServices()

    private var firebaseReferenceContainer: ReferenceHolding?
    private var firebaseObserverUtility: ReferenceObserving?

    private init() {}

    public func setupCore(with params: MeetingsParams,
                          referenceContainer: ReferenceHolding,
                          observerUtility: ReferenceObserving,
                          meetingIdentifier: String) {
        meetingParams = params
        firebaseReferenceContainer = referenceContainer
        firebaseObserverUtility = observerUtility

        firebaseObserverUtility?.setObserver(teamBoostCore: self)
        firebaseReferenceContainer?.setupDefaultValues(with: meetingParams!)

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
        firebaseReferenceContainer?.setReferenceForMeetingStarted()
    }

    public func endMeeting() {
        firebaseReferenceContainer?.setReferenceForMeetingEnded()
    }

    public func updateSpeakerOrder(with identifiers: [String]) {
        speakerOrder = identifiers
        firebaseReferenceContainer?.setReferenceForSpeakerOrder(speakingOrder: speakerOrder!)

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
        firebaseReferenceContainer?.testModeSetReferenceForNoParticipants()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.testEnvironment == true {
                self.firebaseReferenceContainer?.testModeSetReferenceForFakeParticipants()
            }
        }
    }
}
