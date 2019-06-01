//
//  ParticipantControllerService.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 30.05.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

protocol ParticipantTimeUpdatable: class {
    func updateTime(participantLeftSpeakingTime: Int,
                    meetingLeftTime: Int)
    func updateSpeakingOrder(speakingOrder: [String])
}

class ParticipantControllerService {
    let meetingParams: MeetingsParams
    let meetingTime: Int

    private var secondTickTimer: Timer?
    private var secondTimerCountForParticipant = 0
    private var secondTimerCountForMeeting = 0
    private var currentSpeakerMaxTalkTime: Int?
    private var speakerOrder: [String]?

    private weak var participantTimeUpdateable: ParticipantTimeUpdatable?

    init(with meetingParams: MeetingsParams,
         timesUpdatedObserver: ParticipantTimeUpdatable) {
        self.meetingParams = meetingParams
        self.meetingTime = meetingParams.meetingTime * 60
        self.participantTimeUpdateable = timesUpdatedObserver
        self.currentSpeakerMaxTalkTime = ParticipantCoreServices.shared.meetingParams?.maxTalkTime
        self.speakerOrder = ParticipantCoreServices.shared.speakerOrder

        startSecondTickerTimer()
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

        participantTimeUpdateable?.updateTime(participantLeftSpeakingTime: participantTimeLeft,
                                              meetingLeftTime: meetingTimeLeft)
    }

    private func setupSpeakerOrderObserver() {
        let notificationName = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(speakerOrderDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func speakerOrderDidChange(notification: NSNotification) {
        let speakerOrder = (notification.object as? [String]) ?? []
        secondTimerCountForParticipant = 0
        currentSpeakerMaxTalkTime = meetingParams.maxTalkTime
        participantTimeUpdateable?.updateSpeakingOrder(speakingOrder: speakerOrder)
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
