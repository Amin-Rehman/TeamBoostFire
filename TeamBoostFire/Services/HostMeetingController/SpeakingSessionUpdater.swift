//
//  MeetingControllerCurrentRoundTicker.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 29.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import TeamBoostKit

@objc protocol MeetingControllerCurrentRoundTickerObserver: class {
    @objc func speakerIsDone()
}

class SpeakingSessionUpdater: TimerControllerObserver {

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
    public func stop() {
        timerController.stop()
    }

    public func start(where completedSessionSpeakerOrder: [String],
                      isStartOfMeeting: Bool = false) {
        adjustOrderForNewSession(previousSessionSpeakerOrder: completedSessionSpeakerOrder,
                                 isStartOfMeeting: isStartOfMeeting)
        fireNewSpeakingRoundStartedNotification()
        startTheCurrentSpeakingSession()
        iterationInCurrentRound += 1
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
        startTheCurrentSpeakingSession()
    }
}

// MARK: Private Helpers
extension SpeakingSessionUpdater {
    private func makeNewRoundRecord() -> [SpeakerRecord] {
        switch meetingMode {
        case .AutoModerated:
            let speakingRecordsForNewRound = MeetingOrderEvaluator.evaluateOrder(
                participantTotalSpeakingRecord: storage.participantTotalSpeakingRecord,
                maxTalkingTime: maxTalkTime)
            return speakingRecordsForNewRound
        case .Uniform:
            var speakingRecord = [SpeakerRecord]()
            // TODO: Remove force wrap
            let allParticipants = self.storage.domain.allParticipants
            for participant in allParticipants {
                let speakerRecord = SpeakerRecord(participantId: participant.id , speakingTime: self.maxTalkTime)
                speakingRecord.append(speakerRecord)
            }
            return speakingRecord
        }
    }

    private func startTheCurrentSpeakingSession() {
        let currentSpeakingTime = storage.participantSpeakingRecordPerRound[iterationInCurrentRound].speakingTime
        timerController.start(with: Double(currentSpeakingTime))
    }

    private func adjustOrderForNewSession(previousSessionSpeakerOrder: [String],
                                          isStartOfMeeting: Bool) {
        let callToSpeakerQueue = self.storage.callToSpeakerQueue
        let isSomeOneCallingToSpeaker = callToSpeakerQueue.count > 0
        let isNewRound = iterationInCurrentRound == storage.participantSpeakingRecordPerRound.count

        // TODO: Perhaps could have a switch statement here.

        // There is someone in the call to speaker queue; give them preference
        if isSomeOneCallingToSpeaker {
            // Reset the round
            iterationInCurrentRound = 0
            let speakingRecord = makeNewRoundRecord()

            let adjustedSpeakingRecord = MeetingOrderEvaluator.makeSpeakerRecord(
                originalSpeakerRecord: speakingRecord,
                callToSpeakerQueue: callToSpeakerQueue)

            storage.updateSpeakingRecordPerRound(speakerRecord: adjustedSpeakingRecord)
            self.storage.clearCallToSpeakerQueue()

        } else if isNewRound {
            /**
             This is a new round: i.e we have gone through the complete round robin of participants
             for the current session
             */
            iterationInCurrentRound = 0

            // For every round re-evaluate the meeting record for that round
            let speakingRecordsForNewRound = makeNewRoundRecord()
            storage.updateSpeakingRecordPerRound(speakerRecord: speakingRecordsForNewRound)
        } else {
            /**
             We are still in the midst of the round robin; go to the next participant
             */
            storage.updateSpeakerOrder(isStartOfMeeting: isStartOfMeeting)
        }
    }

    private func fireNewSpeakingRoundStartedNotification() {
        DispatchQueue.main.async {
            let name = Notification.Name(AppNotifications.newMeetingRoundStarted.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: nil)
        }
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
