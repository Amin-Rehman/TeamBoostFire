//
//  MeetingOrderEvaluator.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 16.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

public struct SpeakerRecord: Equatable {
    let participantId: ParticipantId
    let speakingTime: SpeakingTime

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.participantId == rhs.participantId && lhs.speakingTime == rhs.speakingTime
    }

}

struct MeetingOrderEvaluator {
    static func evaluateOrder(participantTotalSpeakingRecord: ParticipantSpeakingRecord,
                              maxTalkingTime: SpeakingTime)
        -> [SpeakerRecord] {
            // TODO: Sort First
            // Then evaluate the speaking order

            var allMeetingRecords = [SpeakerRecord]()
            for (participantId, speakingTime) in participantTotalSpeakingRecord {
                let meetingRecord = SpeakerRecord(participantId: participantId,
                                                  speakingTime: speakingTime)
                allMeetingRecords.append(meetingRecord)

            }

            let sortedMeetingRecords = allMeetingRecords.sorted { (lhs, rhs) -> Bool in
                return lhs.speakingTime < rhs.speakingTime
            }

            let numberOfParticipants = sortedMeetingRecords.count

            if (numberOfParticipants <= 2) {
                return sortedMeetingRecords
            } else if (numberOfParticipants == 3) {
                var adjustedRoundMeetingRecord = [SpeakerRecord]()

                for (index, meetingRecord) in sortedMeetingRecords.enumerated(){
                    if (index == 0) {
                        let adjustedSpeakingTime = Double(maxTalkingTime) +
                            ceil((Double(maxTalkingTime) * 0.5))
                        adjustedRoundMeetingRecord.append(
                            SpeakerRecord(participantId: meetingRecord.participantId,
                                          speakingTime: SpeakingTime(adjustedSpeakingTime)))
                    } else {
                        adjustedRoundMeetingRecord.append(
                            SpeakerRecord(participantId: meetingRecord.participantId,
                                          speakingTime: maxTalkingTime))
                    }
                }
                return adjustedRoundMeetingRecord

            } else {
                var adjustedRoundMeetingRecord = [SpeakerRecord]()

                for (index, meetingRecord) in sortedMeetingRecords.enumerated(){
                    if (index == 0) {
                        let adjustedSpeakingTime = Double(maxTalkingTime) +
                            ceil((Double(maxTalkingTime) * 0.5))
                        adjustedRoundMeetingRecord.append(
                            SpeakerRecord(participantId: meetingRecord.participantId,
                                          speakingTime: SpeakingTime(adjustedSpeakingTime)))
                    } else if (index == 1) {
                        let adjustedSpeakingTime = Double(maxTalkingTime) +
                            ceil((Double(maxTalkingTime) * 0.35))
                        adjustedRoundMeetingRecord.append(
                            SpeakerRecord(participantId: meetingRecord.participantId,
                                          speakingTime: SpeakingTime(adjustedSpeakingTime)))
                    } else if (index == 2) {
                        let adjustedSpeakingTime = Double(maxTalkingTime) +
                            ceil((Double(maxTalkingTime) * 0.20))
                        adjustedRoundMeetingRecord.append(
                            SpeakerRecord(participantId: meetingRecord.participantId,
                                          speakingTime: SpeakingTime(adjustedSpeakingTime)))
                    } else {
                        adjustedRoundMeetingRecord.append(
                            SpeakerRecord(participantId: meetingRecord.participantId,
                                          speakingTime: maxTalkingTime))
                    }

                }
                return adjustedRoundMeetingRecord
            }
    }

    static func makeSpeakerRecord(originalSpeakerRecord: [SpeakerRecord],
                                  callToSpeakerQueue: [ParticipantId]) -> [SpeakerRecord] {

        let preferredSpeakingRecords = originalSpeakerRecord.filter { (speakerRecord) -> Bool in
            callToSpeakerQueue.contains(speakerRecord.participantId)
        }

        let nonPreferredSpeakingRecords = originalSpeakerRecord.filter { (speakerRecord) -> Bool in
            !callToSpeakerQueue.contains(speakerRecord.participantId)
        }

        let adjustedSpeakingRecord = preferredSpeakingRecords + nonPreferredSpeakingRecords
        return adjustedSpeakingRecord

    }
}
