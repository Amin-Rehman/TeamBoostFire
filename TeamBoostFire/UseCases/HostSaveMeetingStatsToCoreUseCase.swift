//
//  HostSaveMeetingStatsToCoreUseCase.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 08.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import TeamBoostKit

/**
 Save statistics of the meeting to Host Core Services
 */
struct HostSaveMeetingStatsToCoreUseCase {
    static func perform(meetingLengthSeconds: Int,
                        hostControllerService: HostMeetingControllerService?,
                        domain: TeamBoostKitDomain) {
        guard let controllerService = hostControllerService else {
            assertionFailure("Unable to retrieve host controller service for HostSaveMeetingStatsToCoreUseCase")
            return
        }
        let meetingAgenda = controllerService.meetingParams.agenda
        let participantSpeakingRecordWithId = controllerService.storage.participantTotalSpeakingRecord


        let allParticipants = domain.allParticipants
        var participantSpeakingRecordWithName = [String: Int]()
        for participant in allParticipants {
            let participantSpeakingTime = participantSpeakingRecordWithId[participant.id]
            if participantSpeakingTime != 0 {
                participantSpeakingRecordWithName[participant.name] = participantSpeakingTime
            }
        }

        domain.meetingStatistics = MeetingStats(
            agenda: meetingAgenda,
            meetingLength: meetingLengthSeconds,
            numberOfParticipants: allParticipants.count,
            participantSpeakingRecords: participantSpeakingRecordWithName
        )
    }

}
