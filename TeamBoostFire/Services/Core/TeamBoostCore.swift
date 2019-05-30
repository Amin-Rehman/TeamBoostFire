//
//  CoreServices.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation

protocol TeamBoostCore: class {
    var speakerOrder: [String]? { get set }
    var allParticipants: [Participant]? { get set }
    var meetingParams: MeetingsParams? { get set }
}


