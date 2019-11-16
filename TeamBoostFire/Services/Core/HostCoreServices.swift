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

    private var firebaseReferenceHolder: ReferenceHolding?
    private var firebaseReferenceObserver: ReferenceObserving?

    private init() {}

    public func setupCore(with params: MeetingsParams,
                          referenceContainer: ReferenceHolding,
                          observerUtility: ReferenceObserving,
                          meetingIdentifier: String) {
        meetingParams = params
        firebaseReferenceHolder = referenceContainer
        firebaseReferenceObserver = observerUtility

        firebaseReferenceObserver?.setObserver(teamBoostCore: self)
        firebaseReferenceHolder?.setupDefaultValues(with: meetingParams!)

        firebaseReferenceObserver?.observeParticipantListChanges()
        firebaseReferenceObserver?.observeSpeakerOrderDidChange()
        firebaseReferenceObserver?.observeIAmDoneInterrupt()

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
        firebaseReferenceHolder?.setReferenceForMeetingStarted()
    }

    public func endMeeting() {
        firebaseReferenceHolder?.setReferenceForMeetingEnded()
    }

    public func updateSpeakerOrder(with identifiers: [String]) {
        speakerOrder = identifiers
        firebaseReferenceHolder?.setReferenceForSpeakerOrder(speakingOrder: speakerOrder!)

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
        firebaseReferenceHolder?.testModeSetReferenceForNoParticipants()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.testEnvironment == true {
                self.firebaseReferenceHolder?.testModeSetReferenceForFakeParticipants()
            }
        }
    }
}
