//
//  MeetingControllerStorage.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 25.08.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import TeamBoostKit

typealias ParticipantSpeakingRecord = [ParticipantId: SpeakingTime]

// This storage class contains the total speaking time in the meeting and the speaking time per record
class MeetingControllerStorage {

    // To be updated for every round if speaking time needs to be adjusted
    private(set) public var participantSpeakingRecordPerRound = [SpeakerRecord]()
    private(set) public var participantTotalSpeakingRecord = ParticipantSpeakingRecord()
    private(set) public var activeMeetingTime = Int(0)

    public let domain: HostDomain

    private(set) public var callToSpeakerQueue = [ParticipantId]()

    public var speakingRecord: [String] {
        var newSpeakingOrder = [String]()
        participantSpeakingRecordPerRound.forEach { speakerRecord in
            newSpeakingOrder.append(speakerRecord.participantId)
        }
        return newSpeakingOrder
    }

    init(with participantIds: [ParticipantId],
         maxTalkTime: Int,
         domain: HostDomain) {
        self.domain = domain
        participantIds.forEach { identifier in
            participantTotalSpeakingRecord[identifier] = 0
            participantSpeakingRecordPerRound.append(
                SpeakerRecord(participantId: identifier,
                              speakingTime: maxTalkTime))
        }
    }

    // MARK:- Accessors / Setters
    func updateSpeakingRecordPerRound(speakerRecord: [SpeakerRecord]) {
        participantSpeakingRecordPerRound = speakerRecord
        domain.updateSpeakerOrder(with: self.speakingRecord)
    }

    func updateSpeakerOrder(isStartOfMeeting: Bool) {
        let speakerOrder = domain.speakerOrder
        let proposedNewSpeakingOrder = isStartOfMeeting ? speakerOrder: speakerOrder.circularRotate()
        domain.updateSpeakerOrder(with: proposedNewSpeakingOrder)
    }

    func updateTotalSpeakingTime(for participantId: String,
                                 newTime: Int) {
        participantTotalSpeakingRecord[participantId] = newTime
    }

    func incrementMeetingTime() {
        activeMeetingTime = activeMeetingTime + 1
    }

    // MARK: - Call to Speaker
    func appendSpeakerToCallToSpeakerQueue(participantId: ParticipantId) {
        self.callToSpeakerQueue.append(participantId)
    }

    func clearCallToSpeakerQueue() {
        self.callToSpeakerQueue = [ParticipantId]()
    }
}
