//
//  TeamBoostNotifications.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

public enum TeamBoostNotifications: String {
    case meetingCodeDidChange = "MeetingCodeDidChange"
    case participantListDidChange = "ParticipantListDidChange"
    case meetingStateDidChange = "MeetingStateDidChange"
    case meetingParamsDidChange = "MeetingParamsDidChange"
    case speakerOrderDidChange = "SpeakerOrderDidChange"
    case participantIsDoneInterrupt = "ParticipantIsDoneInterrupt"
    case currentParticipantMaxSpeakingTimeChanged = "CurrentParticipantMaxSpeakingTimeChanged"
    case callToSpeakerDidChange = "CallToSpeakerDidChange"
    case moderatorHasControlDidChange = "ModeratorHasControlDidChange"
}
