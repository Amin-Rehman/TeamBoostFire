//
//  PartcipantSelfSpeakerViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 02.05.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantSelfSpeakerViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        updateSpeakingTimerLabel()

        let notificationName = Notification.Name(TeamBoostNotifications.meetingStateDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(meetingStateDidChange(notification:)),
                                               name: notificationName, object: nil)

    }

    @IBAction func doneTapped(_ sender: Any) {
        ParticipantCoreServices.shared.registerParticipantIsDoneInterrupt()
//        dismiss(animated: true, completion: nil)
    }

    private func updateSpeakingTimerLabel() {
        let timeElapsedString = 0.minutesAndSecondsPrettyString()
        timerLabel.text = timeElapsedString
    }
}

extension ParticipantSelfSpeakerViewController: ParticipantUpdatable {
    func updateTime(participantLeftSpeakingTime: Int, meetingLeftTime: Int) {
        timerLabel.text = participantLeftSpeakingTime.minutesAndSecondsPrettyString()
    }

    func updateSpeakingOrder(speakingOrder: [String]) {
        dismiss(animated: true, completion: nil)
    }

    @objc private func meetingStateDidChange(notification: NSNotification) {
        let meetingState = notification.object as! MeetingState
        if meetingState == .ended {
            dismiss(animated: true, completion: nil)
        }
    }
}
