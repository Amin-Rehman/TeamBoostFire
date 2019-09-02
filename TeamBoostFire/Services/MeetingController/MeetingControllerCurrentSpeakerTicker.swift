//
//  MeetingControllerCurrentRoundTicker.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 29.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

@objc protocol MeetingControllerCurrentRoundTickerObserver: class {
    @objc func speakerIsDone()
}

class MeetingControllerCurrentSpeakerTicker: TimerControllerObserver {

    let storage: MeetingControllerStorage
    let meetingMode: MeetingMode
    weak var observer: MeetingControllerCurrentRoundTickerObserver?
    let maxTalkTime: Int
    let timerController: TimerController

    private var iterationInCurrentRound = 0

    init(with storage: MeetingControllerStorage,
         meetingMode: MeetingMode,
         maxTalkTime: Int,
         observer: MeetingControllerCurrentRoundTickerObserver,
         timerController: TimerController) {
        self.storage = storage
        self.meetingMode = meetingMode
        self.observer = observer
        self.maxTalkTime = maxTalkTime
        self.timerController = timerController
        self.timerController.observer = self
    }

    func notifyTimerIsDone() {
        observer?.speakerIsDone()
    }


    public func start() {
        switch meetingMode {
        case .Uniform:
            timerController.start(with: Double(maxTalkTime))

        case .AutoModerated:
            // FIXME: Maybe use total number of participants as a parameter
            let isNewRound = iterationInCurrentRound == storage.participantSpeakingRecordPerRound.count

            if isNewRound {
                iterationInCurrentRound = 0

                let speakingRecordsForNewRound = MeetingOrderEvaluator.evaluateOrder(
                    participantTotalSpeakingRecord: storage.participantTotalSpeakingRecord,
                    maxTalkingTime: maxTalkTime)!

                storage.updateSpeakingRecordPerRound(speakingRecord: speakingRecordsForNewRound)
                HostCoreServices.shared.updateSpeakerOrder(with: storage.speakingRecord)
            }

            let currentSpeakingTime = storage.participantSpeakingRecordPerRound[iterationInCurrentRound].speakingTime
            timerController.start(with: Double(currentSpeakingTime))
        }
    }

    public func stop() {
        timerController.stop()
    }
}
