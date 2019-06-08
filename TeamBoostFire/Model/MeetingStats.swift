//
//  MeetingStats.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 08.06.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

typealias ParticipantName = String

struct MeetingStats {
    let agenda: String
    let meetingLength: Int
    let numberOfParticipants: Int
    // Will be used in the pie chart
    let participantSpeakingRecords: [ParticipantName: Int]
}
