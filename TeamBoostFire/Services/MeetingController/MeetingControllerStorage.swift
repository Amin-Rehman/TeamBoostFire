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
    private(set) public var participantSpeakingRecordPerRound = [SpeakerRecord]()
    private(set) public var participantTotalSpeakingRecord = ParticipantSpeakingRecord()

    public var speakingRecord: [String] {
        var newSpeakingOrder = [String]()
        participantSpeakingRecordPerRound.forEach { speakerRecord in
            newSpeakingOrder.append(speakerRecord.participantId)
        }
        return newSpeakingOrder
    }

    init(with participantIds: [ParticipantId],
         maxTalkTime: Int) {
        participantIds.forEach { identifier in
            participantTotalSpeakingRecord[identifier] = 0
            participantSpeakingRecordPerRound.append(
                SpeakerRecord(participantId: identifier,
                              speakingTime: maxTalkTime))
        }
    }

    // MARK:- Accessors
    func updateSpeakingRecordPerRound(speakingRecord: [SpeakerRecord]) {
        participantSpeakingRecordPerRound = speakingRecord
    }

    func updateTotalSpeakingTime(for participantId: String,
                                 newTime: Int) {
        participantTotalSpeakingRecord[participantId] = newTime
    }

}
