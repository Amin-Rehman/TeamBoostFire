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

        var meetingIdentifier: String
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.testEnvironment == true {
            meetingIdentifier = StubMeetingVars.MeetingCode.rawValue
        } else {
            meetingIdentifier = String.makeSixDigitRandomNumbers()
        }

        let firebaseReferenceHolder = FirebaseReferenceHolder(with: meetingIdentifier)
        let firebaseReferenceObserver = FirebaseReferenceObserver(with: firebaseReferenceHolder)

        appDelegate.makeHostDomain(referenceObserver: firebaseReferenceObserver,
                                   referenceHolder: firebaseReferenceHolder,
                                   meetingIdentifier: meetingIdentifier,
                                   meetingParams: meetingParams)

        firebaseReferenceHolder.setupDefaultValues(with: meetingParams)
        injectFakeParticipantsForTestModeIfNeeded(referenceHolder: firebaseReferenceHolder)

        let hostWaitingViewController = HostWaitingViewController(nibName: "HostWaitingViewController", bundle: nil)
        viewController.navigationController?.pushViewController(hostWaitingViewController, animated: true)

        DispatchQueue.main.async {
            let name = Notification.Name(TeamBoostNotifications.meetingCodeDidChange.rawValue)
            NotificationCenter.default.post(name: name,
                                            object: meetingIdentifier)
        }
    }

    private static func injectFakeParticipantsForTestModeIfNeeded(referenceHolder: FirebaseReferenceHolder) {
        referenceHolder.testModeSetReferenceForNoParticipants()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if appDelegate.testEnvironment == true {
                referenceHolder.testModeSetReferenceForFakeParticipants()
            }
        }
    }
}



// MARK: - String extension
extension String {
    fileprivate static func makeSixDigitUUID() -> String {
        let shortUUID = UUID().uuidString.lowercased()
        return shortUUID.components(separatedBy: "-").first!
    }

    fileprivate static func makeSixDigitRandomNumbers() -> String {
        let number1 = Int.random(in: 0 ..< 10)
        let number2 = Int.random(in: 0 ..< 10)
        let number3 = Int.random(in: 0 ..< 10)
        let number4 = Int.random(in: 0 ..< 10)
        let number5 = Int.random(in: 0 ..< 10)
        let number6 = Int.random(in: 0 ..< 10)
        return String("\(number1)\(number2)\(number3)-\(number4)\(number5)\(number6)")
    }
}

