//
//  ParticipantMainViewController.swift
//  TeamBoostFire
//
//  Created by Amin Rehman on 18.04.19.
//  Copyright © 2019 Amin Rehman. All rights reserved.
//

import UIKit

class ParticipantMainViewController: UIViewController {

    @IBOutlet weak var agendaQuestionLabel: UILabel!
    @IBOutlet weak var meetingTimeLabel: UILabel!

    @IBOutlet weak var speakerSpeakingTimeLabel: UILabel!
    @IBOutlet weak var currentSpeakerLabel: UILabel!

    @IBOutlet weak var speakingOrderLabel: UILabel!

    private var speakerOrder = [String]()
    private var allParticipants = [Participant]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSpeakerOrderObserver()
    }

    private func setupSpeakerOrderObserver() {
        let notificationName = Notification.Name(TeamBoostNotifications.speakerOrderDidChange.rawValue)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(speakerOrderDidChange(notification:)),
                                               name: notificationName, object: nil)
    }

    @objc private func speakerOrderDidChange(notification: Notification) {
        // Update current speaker
        let currentSpeakingParticipant = currentSpeaker()!
        currentSpeakerLabel.text = currentSpeakingParticipant.name

        // Update self speaking order
        let selfSpeakingOrder = speakingOrder()
        speakingOrderLabel.text = "Speaking Order: \(selfSpeakingOrder)"
    }

    @IBAction func likeButtonTapped(_ sender: Any) {
    }


    @IBAction func continueButtonTapped(_ sender: Any) {
    }

    @IBAction func callForSpeakerTapped(_ sender: Any) {
    }

    private func currentSpeaker() -> Participant? {
        let speakerOrder = CoreServices.shared.speakerOrder!
        let allParticipants = CoreServices.shared.allParticipants!
        let currentSpeakerIdentifier = speakerOrder.first!

        for participant in allParticipants {
            if participant.id == currentSpeakerIdentifier {
                return participant
            }
        }

        assertionFailure("Current speaker not found")
        return nil
    }

    private func speakingOrder() -> Int {
        let speakerOrder = CoreServices.shared.speakerOrder!
        let selfIdentifier = CoreServices.shared.selfIdentifier!
        return speakerOrder.firstIndex(of: selfIdentifier)!
    }

}
