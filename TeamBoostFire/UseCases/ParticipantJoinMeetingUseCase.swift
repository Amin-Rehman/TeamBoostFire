//
//  ParticipantJoinMeetingUseCase.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import UIKit

struct ParticipantJoinMeetingUseCase {
    static func perform(at viewController: UIViewController, participant: Participant, meetingCode: String) {
        CoreServices.shared.setupMeetingAsParticipant(participant: participant, meetingCode: meetingCode)
    }
}

