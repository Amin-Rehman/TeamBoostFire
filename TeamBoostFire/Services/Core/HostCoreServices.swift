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
                          referenceHolder: ReferenceHolding,
                          referenceObserver: ReferenceObserving,
                          meetingIdentifier: String) {
        self.meetingIdentifier = meetingIdentifier
        meetingParams = params
        firebaseReferenceHolder = referenceHolder
        firebaseReferenceObserver = referenceObserver
        firebaseReferenceHolder?.setupDefaultValues(with: meetingParams!)
        setupObservers()

        injectFakeParticipantsForTestModeIfNeeded()
    }

    private func setupObservers() {
        firebaseReferenceObserver?.observeParticipantListChanges(subscriber: { allParticipants in
            self.allParticipants = allParticipants

            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.participantListDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: allParticipants)
            }
        })
        firebaseReferenceObserver?.observeSpeakerOrderDidChange(subscriber: { speakerOrder in
            self.speakerOrder = speakerOrder

            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: speakerOrder)
            }
        })

        firebaseReferenceObserver?.observeIAmDoneInterrupt(subscriber: {
            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.participantIsDoneInterrupt.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: nil)
            }
        })

        firebaseReferenceObserver?.observeCallToSpeakerDidChange(subscriber: { callToSpeakerId in
            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.callToSpeakerDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: callToSpeakerId)
            }
        })
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

    public func setModeratorControlState(controlState: Bool) {
        firebaseReferenceHolder?.setReferenceForModeratorHasControl(controlState: controlState)
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
