//
//  MeetingStats.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 08.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

public typealias ParticipantName = String

public struct MeetingStats {
    public let agenda: String
    public let meetingLength: Int
    public let numberOfParticipants: Int
    // Will be used in the pie chart
    public let participantSpeakingRecords: [ParticipantName: Int]

    public init(agenda: String,
                meetingLength: Int,
                numberOfParticipants: Int,
                participantSpeakingRecords: [ParticipantName: Int]) {
        self.agenda = agenda
        self.meetingLength = meetingLength
        self.numberOfParticipants = numberOfParticipants
        self.participantSpeakingRecords = participantSpeakingRecords
    }
}
