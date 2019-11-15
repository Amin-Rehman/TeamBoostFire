//
//  MeetingParams.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

enum MeetingMode {
    case Uniform
    case AutoModerated
}

public struct MeetingsParams {
    let agenda: String
    let meetingTime: Int
    let maxTalkTime: Int
    let moderationMode: MeetingMode?
}
