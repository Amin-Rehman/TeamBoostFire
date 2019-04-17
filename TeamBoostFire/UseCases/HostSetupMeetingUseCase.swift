//
//  HostSetupMeetingUseCase.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import Foundation
import UIKit

struct HostSetupMeetingUseCase {
    static func perform(at viewController: UIViewController,
                        meetingParams: MeetingsParams) {
        let coreServices = CoreServices.shared
        coreServices.setupMeeting(with: meetingParams)


    }

}

