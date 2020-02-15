//  Created by Amin Rehman on 30.05.19.

import Foundation
import Firebase
import FirebaseDatabase

class ParticipantCoreServices: TeamBoostCore {
    var speakerOrder: [String]?
    var allParticipants: [Participant]?
    var meetingParams: MeetingsParams?

    static let shared = ParticipantCoreServices()
    private(set) public var meetingIdentifier: String?
    private(set) public var selfParticipantIdentifier: String?

    private var firebaseReferenceHolder: ReferenceHolding?
    private var firebaseReferenceObserver: ReferenceObserving?

    private init() {}

    public func setupCore(with participant: Participant,
                          referenceHolder: ReferenceHolding,
                          referenceObserver: ReferenceObserving,
                          meetingCode: String) {
        selfParticipantIdentifier = participant.id

        firebaseReferenceObserver = referenceObserver
        firebaseReferenceHolder = referenceHolder
        firebaseReferenceHolder?.setParticipantReference(participantName: participant.name, participantId: participant.id)

        setupObservers()
    }

    private func setupObservers() {
        firebaseReferenceObserver?.observeParticipantListChanges(subscriber: { allParticipants in
            self.allParticipants = allParticipants
        })

        firebaseReferenceObserver?.observeMeetingStateDidChange(subscriber: {
            meetingState in

            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: meetingState)
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

        firebaseReferenceObserver?.observeMeetingParamsDidChange(subscriber: { meetingParams in
            self.meetingParams = meetingParams

            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.meetingParamsDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: meetingParams)
            }
        })

        firebaseReferenceObserver?.observeParticipantListChanges(subscriber: { allParticipants in
            self.allParticipants = allParticipants
        })

        firebaseReferenceObserver?.observeMeetingStateDidChange(subscriber: {
            meetingState in
            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: meetingState)
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

        firebaseReferenceObserver?.observeMeetingParamsDidChange(subscriber: { meetingParams in
            self.meetingParams = meetingParams
            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.meetingParamsDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: meetingParams)
            }
        })

        firebaseReferenceObserver?.observeModeratorHasControlDidChange(subscriber: { moderatorControlState in
            DispatchQueue.main.async {
                let name = Notification.Name(TeamBoostNotifications.moderatorHasControlDidChange.rawValue)
                NotificationCenter.default.post(name: name,
                                                object: moderatorControlState)
            }
        })

    }

    public func registerParticipantIsDoneInterrupt() {
        let timeStampOfInterrupt = Date().timeIntervalSinceReferenceDate
        firebaseReferenceHolder?.setIAmDoneInterruptReference(timeInterval: timeStampOfInterrupt)
    }

    public func registerCallToSpeaker() {
        guard let callToSpeakerValue = selfParticipantIdentifier else {
            assertionFailure("Unable to register call to speaker value")
            return
        }

        let uuid = UUID().uuidString
        let uniqueCallToSpeakerValue = callToSpeakerValue + "_" + uuid
        firebaseReferenceHolder?.setCallToSpeakerReference(callToSpeakerReferenceValue: uniqueCallToSpeakerValue)
    }
}
