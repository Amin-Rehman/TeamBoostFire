//
//  MeetingControllerStorage.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 25.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

typealias ParticipantSpeakingRecord = [ParticipantId: SpeakingTime]


class MeetingControllerStorage {

    // To be updated for every round if speaking time needs to be adjusted
    public var participantSpeakingRecordPerRound = [SpeakerRecord]()
    public var participantTotalSpeakingRecord = ParticipantSpeakingRecord()

    init(with participantIds: [ParticipantId],
         maxTalkTime: Int) {
        participantIds.forEach { identifier in
            participantTotalSpeakingRecord[identifier] = 0
            participantSpeakingRecordPerRound.append(
                SpeakerRecord(participantId: identifier,
                              speakingTime: maxTalkTime))
        }

    }
}
