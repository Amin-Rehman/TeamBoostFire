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
                print("ALOG: MeetingControllerCurrentSpeakerTicker: newRound detected")
                let speakingRecordsForNewRound = makeNewRoundRecord()
                storage.updateSpeakingRecordPerRound(speakerRecord: speakingRecordsForNewRound)

                DispatchQueue.main.async {
                    let name = Notification.Name(AppNotifications.newMeetingRoundStarted.rawValue)
                    NotificationCenter.default.post(name: name,
                                                    object: nil)
                }

            }
            startTheCurrentRound()
        }
        
        iterationInCurrentRound += 1
    }

    public func stop() {
        timerController.stop()
    }

    /**
     Abort the round and provide the ability for the participant to speak
     Create a new speaker record as normal but then inject the participant of interest as the first participant
     */
    public func forceRestartRound(preferParticipantId: ParticipantId) throws {
        stop()
        let speakingRecordsForNewRound = makeNewRoundRecord()
        let adjustedSpeakingRecord = try ParticipantPreferable.prefer(participantIdOfInterest: preferParticipantId,
                                                                  originalSpeakingRecord: speakingRecordsForNewRound)

        storage.updateSpeakingRecordPerRound(speakerRecord: adjustedSpeakingRecord)
        startTheCurrentRound()
    }
}

// MARK: Private Helpers
extension MeetingControllerCurrentSpeakerTicker {
    private func makeNewRoundRecord() -> [SpeakerRecord] {
        iterationInCurrentRound = 0

        let speakingRecordsForNewRound = MeetingOrderEvaluator.evaluateOrder(
            participantTotalSpeakingRecord: storage.participantTotalSpeakingRecord,
            maxTalkingTime: maxTalkTime)!
        return speakingRecordsForNewRound
    }

    private func startTheCurrentRound() {
        let currentSpeakingTime = storage.participantSpeakingRecordPerRound[iterationInCurrentRound].speakingTime
        timerController.start(with: Double(currentSpeakingTime))
    }
}

public struct ParticipantPreferable {
    /**
     Take in the original speaking record and give the participant the opportunity to be the first one to speak
     */
    public static func prefer(participantIdOfInterest: ParticipantId,
                       originalSpeakingRecord: [SpeakerRecord]) throws -> [SpeakerRecord] {
        var adjustedSpeakingRecord = [SpeakerRecord]()

        let participantOfInterest = originalSpeakingRecord.first { speakingRecord -> Bool in
            speakingRecord.participantId == participantIdOfInterest
        }

        guard let preferredParticipant = participantOfInterest else {
            print("WARNING: Preferred speaker not found")
            return originalSpeakingRecord
        }

        adjustedSpeakingRecord = originalSpeakingRecord
        adjustedSpeakingRecord.removeAll { speakerRecord -> Bool in
            speakerRecord.participantId == participantIdOfInterest
        }

        adjustedSpeakingRecord.insert(preferredParticipant, at: 0)
        return adjustedSpeakingRecord
    }

}
