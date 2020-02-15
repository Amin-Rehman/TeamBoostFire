//
//  ParticipantControllerService.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 30.05.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

enum ParticipantControllerInMeetingState: Equatable {
    case unknown
    case selfIsSpeaking
    case anotherParticipantIsSpeaking(participantName: String)
    case moderatorIsSpeaking
}

protocol RemainingMeetingTimeUpdater: class {
    func updateTime(meetingLeftTime: Int)
}

protocol ParticipantControllerInMeetingStateObserver: class {
    func participantInMeetingStateDidChange(state: ParticipantControllerInMeetingState)
}

struct InMeetingStateEvaluator {
    public let selfIdentifier: String
    public let allParticipants: [Participant]
    public var speakerOrder: [String]?
    public var moderatorIsSpeaking: Bool = false

    var inMeetingState: ParticipantControllerInMeetingState {
        get {
            if moderatorIsSpeaking {
                return ParticipantControllerInMeetingState.moderatorIsSpeaking
            }

            guard let guardedSpeakerOrder = speakerOrder else {
                return ParticipantControllerInMeetingState.unknown
            }

            if isSpeakerSelf(with: guardedSpeakerOrder) {
                return ParticipantControllerInMeetingState.selfIsSpeaking
            }

            let currentSpeakerIdentifier = speakerOrder![0]
            let speakingParticipant = allParticipants.first { (participant) -> Bool in
                participant.id == currentSpeakerIdentifier
            }

            guard let guardedSpeakingParticipant = speakingParticipant else {
                return ParticipantControllerInMeetingState.unknown
            }

            return
                ParticipantControllerInMeetingState.anotherParticipantIsSpeaking(participantName: guardedSpeakingParticipant.name)

        }
    }

    private func isSpeakerSelf(with speakerOrder: [String]) -> Bool {
        return (speakerOrder.firstIndex(of: selfIdentifier) == 0)
        }

}

class ParticipantControllerService {
    let meetingParams: MeetingsParams
    let meetingTime: Int

    private var secondTickTimer: Timer?
    private var secondTimerCountForParticipant = 0
    private var secondTimerCountForMeeting = 0
    private var currentSpeakerMaxTalkTime: Int?

    private weak var remainingMeetingTimeUpdater: RemainingMeetingTimeUpdater?
    public weak var inMeetingStateObserver: ParticipantControllerInMeetingStateObserver?

    private var inMeetingStateEvaluator: InMeetingStateEvaluator
    // Only to perform a certain level of debouncing
    private var persistedInMeetingState: ParticipantControllerInMeetingState

    private(set) public var allParticipants: [Participant]?  = {
        return ParticipantCoreServices.shared.allParticipants
    }()

    private(set) public var selfIdentifier: String?  = {
        return ParticipantCoreServices.shared.selfParticipantIdentifier
    }()

    init(with meetingParams: MeetingsParams,
         remainingMeetingTimeUpdater: RemainingMeetingTimeUpdater,
         inMeetingStateObserver: ParticipantControllerInMeetingStateObserver) {
        self.meetingParams = meetingParams
        self.meetingTime = meetingParams.meetingTime * 60
        self.remainingMeetingTimeUpdater = remainingMeetingTimeUpdater
        self.inMeetingStateObserver = inMeetingStateObserver
        self.currentSpeakerMaxTalkTime = ParticipantCoreServices.shared.meetingParams?.maxTalkTime
        let speakerOrder = ParticipantCoreServices.shared.speakerOrder
        self.inMeetingStateEvaluator = InMeetingStateEvaluator(selfIdentifier: selfIdentifier!,
                                                               allParticipants: allParticipants!,
                                                               speakerOrder: speakerOrder,
                                                               moderatorIsSpeaking: false)
        self.persistedInMeetingState = inMeetingStateEvaluator.inMeetingState

        startSecondTickerTimer()
        // Keeping track if moderator speaking change changed
        setupModeratorSpeakerTracker()
        // Keeping track if participant speaker order changes
        setupSpeakerOrderObserver()
    }

    private func startSecondTickerTimer() {
        secondTickTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self,
                                               selector: #selector(secondTicked),
                                               userInfo: nil, repeats: true)
    }

    private func stopSecondTickerTimer() {
        secondTickTimer?.invalidate()
        secondTickTimer = nil
    }

    @objc func secondTicked() {
        secondTimerCountForParticipant = secondTimerCountForParticipant + 1
        secondTimerCountForMeeting = secondTimerCountForMeeting + 1
        let meetingTimeLeft = meetingTime - secondTimerCountForMeeting
        remainingMeetingTimeUpdater?.updateTime(meetingLeftTime: meetingTimeLeft)
    }

    private func setupSpeakerOrderObserver() {
        let notificationName = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(speakerOrderDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func speakerOrderDidChange(notification: NSNotification) {
        let speakerOrderFromNotification = (notification.object as? [String]) ?? []
        secondTimerCountForParticipant = 0
        currentSpeakerMaxTalkTime = meetingParams.maxTalkTime
        inMeetingStateEvaluator.speakerOrder = speakerOrderFromNotification
        triggerMeetingStateChangeIfNeeded()
    }

    private func setupModeratorSpeakerTracker() {
        let notificationName = Notification.Name(TeamBoostNotifications.moderatorHasControlDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moderatorHasControlDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func moderatorHasControlDidChange(notification: NSNotification) {
        inMeetingStateEvaluator.moderatorIsSpeaking = notification.object as! Bool
        triggerMeetingStateChangeIfNeeded()
    }

    private func setupCurrentSpeakerMaxTalkTimeChangedObserver() {
        let notificationName = Notification.Name(
            TeamBoostNotifications.currentParticipantMaxSpeakingTimeChanged.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentSpeakerMaxTalkTimeChanged(notification:)),
                                               name: notificationName, object: nil)
    }

    private func triggerMeetingStateChangeIfNeeded() {
        if persistedInMeetingState != inMeetingStateEvaluator.inMeetingState {
            // Trigger is needed
            persistedInMeetingState = inMeetingStateEvaluator.inMeetingState
            inMeetingStateObserver?.participantInMeetingStateDidChange(state: persistedInMeetingState)
        }

        // Otherwise ignore
    }

    @objc private func currentSpeakerMaxTalkTimeChanged(notification: NSNotification) {
//        currentSpeakerMaxTalkTime = notification.object as? Int ??
//            ParticipantCoreServices.shared.meetingParams?.maxTalkTime
        // TODO: Implement this

    }
}
