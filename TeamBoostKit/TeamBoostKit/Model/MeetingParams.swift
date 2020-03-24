//
//  MeetingParams.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

public enum MeetingMode {
    case Uniform
    case AutoModerated
}

public struct MeetingsParams {
    public let agenda: String
    public let meetingTime: Int
    public let maxTalkTime: Int
    public let moderationMode: MeetingMode?

    public init(agenda: String,
                meetingTime: Int,
                maxTalkTime: Int,
                moderationMode: MeetingMode?) {
        self.agenda = agenda
        self.meetingTime = meetingTime
        self.maxTalkTime = maxTalkTime
        self.moderationMode = moderationMode
    }
}
