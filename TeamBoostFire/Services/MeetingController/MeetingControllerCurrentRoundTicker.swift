//
//  MeetingControllerCurrentRoundTicker.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 29.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

@objc protocol MeetingControllerCurrentRoundTickerObserver: class {
    @objc func currentRoundIsComplete()
    func speakingOrderUpdated(totalSpeakingRecord: [ParticipantId: SpeakingTime])
}

class MeetingControllerCurrentRoundTicker {
    let storage: MeetingControllerStorage
    let meetingMode: MeetingMode
    weak var observer: MeetingControllerCurrentRoundTickerObserver?
    var roundTimer: Timer?
    let maxTalkTime: Int

    private var numberOfRounds = 0

    init(with storage: MeetingControllerStorage,
         meetingMode: MeetingMode,
         maxTalkTime: Int,
         observer: MeetingControllerCurrentRoundTickerObserver) {
        self.storage = storage
        self.meetingMode = meetingMode
        self.observer = observer
        self.roundTimer = nil
        self.maxTalkTime = maxTalkTime
    }

    public func start() {

        switch meetingMode {
        case .Uniform:
            roundTimer = Timer.scheduledTimer(timeInterval: Double(maxTalkTime), target: self,
                                              selector: #selector(observer?.currentRoundIsComplete),
                                                userInfo: nil, repeats: false)
        case .AutoModerated:
            // FIXME: Maybe use total number of participants as a parameter
            let isNewRound = numberOfRounds == storage.participantSpeakingRecordPerRound.count

            if isNewRound {
                numberOfRounds = 0
                let speakingRecordForNewRound = MeetingOrderEvaluator.evaluateOrder(
                    participantTotalSpeakingRecord: storage.participantTotalSpeakingRecord,
                    maxTalkingTime: maxTalkTime)!
                storage.updateSpeakingRecordForCurrentRound(speakingRecord: speakingRecordForNewRound)

                HostCoreServices.shared.updateSpeakerOrder(with: storage.speakingRecord)
                observer?.speakingOrderUpdated(totalSpeakingRecord: storage.participantTotalSpeakingRecord)
            }

            roundTimer = Timer.scheduledTimer(
                timeInterval:
                Double(storage.participantSpeakingRecordPerRou  nd[indexForParticipantRoundSpeakingTime].speakingTime),
                target: self,
                selector: #selector(observer?.currentRoundIsComplete),
                userInfo: nil, repeats: false)
        }
    }

    public func stop() {

    }
}
