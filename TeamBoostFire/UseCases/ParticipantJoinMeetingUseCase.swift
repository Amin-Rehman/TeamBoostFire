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
    static func perform(at viewController: UIViewController,
                        participant: Participant,
                        meetingCode: String) {
        var meetingIdentifier = ""
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            meetingIdentifier = StubMeetingVars.MeetingCode.rawValue
        } else {
            meetingIdentifier = meetingCode
        }

        let referenceHolder = FirebaseReferenceHolder(with: meetingIdentifier)
        let referenceObserver = FirebaseReferenceObserver(with: referenceHolder)

        ParticipantCoreServices.shared.setupCore(
            with: participant,
            referenceHolder: referenceHolder,
            referenceObserver: referenceObserver,
            meetingCode: meetingCode)
    }
}

