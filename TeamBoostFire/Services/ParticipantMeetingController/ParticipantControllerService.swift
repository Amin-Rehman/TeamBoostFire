//
//  ParticipantControllerService.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 30.05.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

protocol ParticipantSpeakerTracker: class {
    func updateTime(participantLeftSpeakingTime: Int,
                    meetingLeftTime: Int)
    func updateSpeakingOrder(speakingOrder: [String])
}

protocol ModeratorSpeakerTracker: class {
    func moderatorStartedSpeaking()
    func moderatorStoppedSpeaking()
}


class ParticipantControllerService {
    let meetingParams: MeetingsParams
    let meetingTime: Int

    private var secondTickTimer: Timer?
    private var secondTimerCountForParticipant = 0
    private var secondTimerCountForMeeting = 0
    private var currentSpeakerMaxTalkTime: Int?
    public var speakerOrder: [String]?

    private weak var participantSpeakerTracker: ParticipantSpeakerTracker?
    public weak var moderatorSpeakerTracker: ModeratorSpeakerTracker?

    private(set) public var allParticipants: [Participant]?  = {
        return ParticipantCoreServices.shared.allParticipants
    }()

    private(set) public var selfIdentifier: String?  = {
        return ParticipantCoreServices.shared.selfParticipantIdentifier
    }()

    init(with meetingParams: MeetingsParams,
         participantSpeakerTracker: ParticipantSpeakerTracker,
         moderatorSpeakerTracker: ModeratorSpeakerTracker) {
        self.meetingParams = meetingParams
        self.meetingTime = meetingParams.meetingTime * 60
        self.participantSpeakerTracker = participantSpeakerTracker
        self.moderatorSpeakerTracker = moderatorSpeakerTracker
        self.currentSpeakerMaxTalkTime = ParticipantCoreServices.shared.meetingParams?.maxTalkTime
        self.speakerOrder = ParticipantCoreServices.shared.speakerOrder

        startSecondTickerTimer()
        // Keeping track if moderator speaking change changed
        setupModeratorSpeakerTracker()

        // Keeping track if participant order changes
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
        let participantTimeLeft = currentSpeakerMaxTalkTime! - secondTimerCountForParticipant
        let meetingTimeLeft = meetingTime - secondTimerCountForMeeting

        participantSpeakerTracker?.updateTime(participantLeftSpeakingTime: participantTimeLeft,
                                              meetingLeftTime: meetingTimeLeft)
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
        speakerOrder = speakerOrderFromNotification
        participantSpeakerTracker?.updateSpeakingOrder(speakingOrder: speakerOrderFromNotification)
    }

    private func setupModeratorSpeakerTracker() {
        let notificationName = Notification.Name(TeamBoostNotifications.moderatorHasControlDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moderatorHasControlDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func moderatorHasControlDidChange(notification: NSNotification) {
        let moderatorStartedSpeaking = notification.object as! Bool
        if moderatorStartedSpeaking {
            moderatorSpeakerTracker?.moderatorStartedSpeaking()
        } else {
            moderatorSpeakerTracker?.moderatorStoppedSpeaking()
        }
    }


    private func setupCurrentSpeakerMaxTalkTimeChangedObserver() {
        let notificationName = Notification.Name(
            TeamBoostNotifications.currentParticipantMaxSpeakingTimeChanged.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(currentSpeakerMaxTalkTimeChanged(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func currentSpeakerMaxTalkTimeChanged(notification: NSNotification) {
//        currentSpeakerMaxTalkTime = notification.object as? Int ??
//            ParticipantCoreServices.shared.meetingParams?.maxTalkTime
        // TODO: Implement this

    }


}
