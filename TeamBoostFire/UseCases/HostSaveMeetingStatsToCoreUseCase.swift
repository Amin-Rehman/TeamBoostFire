//
//  HostSaveMeetingStatsToCoreUseCase.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 08.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

/**
 Save statistics of the meeting to Host Core Services
 */
struct HostSaveMeetingStatsToCoreUseCase {
    static func perform(meetingLengthSeconds: Int, hostControllerService: MeetingControllerService?) {
        guard let controllerService = hostControllerService else {
            assertionFailure("Unable to retrieve host controller service for HostSaveMeetingStatsToCoreUseCase")
            return
        }
        let meetingAgenda = controllerService.meetingParams.agenda
        let participantSpeakingRecordWithId = controllerService.participantSpeakingRecord

        guard let allParticipants = HostCoreServices.shared.allParticipants else {
            assertionFailure("Unable to return al participant from Core: HostSaveMeetingStatsToCoreUseCase")
            return
        }

        var participantSpeakingRecordWithName = [String: Int]()
        for participant in allParticipants {
            let participantSpeakingTime = participantSpeakingRecordWithId[participant.id]
            if participantSpeakingTime != 0 {
                participantSpeakingRecordWithName[participant.name] = participantSpeakingTime
            }
        }

        HostCoreServices.shared.meetingStatistics = MeetingStats(
            agenda: meetingAgenda,
            meetingLength: meetingLengthSeconds,
            numberOfParticipants: allParticipants.count,
            participantSpeakingRecords: participantSpeakingRecordWithName
        )
    }

}
