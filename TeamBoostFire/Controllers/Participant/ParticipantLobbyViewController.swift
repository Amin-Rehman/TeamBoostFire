//
//  ParticipantLobbyViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 17.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit
import TransitionButton
import Lottie
import TeamBoostKit

class ParticipantLobbyViewController: CustomTransitionViewController {
    @IBOutlet weak var lottieParticipantWaitingAnimationView: AnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true,
                                                     animated: true)
        let animation = Animation.named("lottie_participant_waiting")
        lottieParticipantWaitingAnimationView.animation = animation
        lottieParticipantWaitingAnimationView.loopMode = .loop
        lottieParticipantWaitingAnimationView.play()
    }

    override func viewDidAppear(_ animated: Bool) {
        let notificationName = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(meetingStateDidChange(notification:)),
                                               name: notificationName, object: nil)

    }

    @objc private func meetingStateDidChange(notification: NSNotification) {
        let meetingState = notification.object as! MeetingState
        if meetingState == .started {
            presentParticipantMainViewController()
            NotificationCenter.default.removeObserver(self)
        }
    }

    func presentParticipantMainViewController() {
        let participantMainViewController = ParticipantMainViewController()
        let meetingParams = ParticipantCoreServices.shared.meetingParams
        let participantControllerService =
            ParticipantControllerService(
                with: meetingParams!,
                remainingMeetingTimeUpdater: participantMainViewController,
                inMeetingStateObserver: participantMainViewController)

        // TODO: Circular dependency , can we avoid this?
        participantMainViewController.participantControllerService = participantControllerService
        navigationController?.pushViewController(participantMainViewController, animated: true)

    }
}
